plugins {
    java
    jacoco
    alias(libs.plugins.spring.boot)
    alias(libs.plugins.spring.dependency.management)
    alias(libs.plugins.spotless)
}

group = "com.example"
version = "0.1.0-SNAPSHOT"

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(25)
    }
}

repositories {
    mavenCentral()
}

dependencies {
    implementation(libs.spring.boot.starter.webmvc)
    implementation(libs.spring.boot.starter.validation)
    implementation(libs.spring.boot.starter.actuator)
    annotationProcessor(libs.spring.boot.configuration.processor)

    // Persistence: uncomment when a spec needs a database (see .claude/rules/spring-boot.md).
    // Integration tests then need Docker for Testcontainers.
    // implementation(libs.spring.boot.starter.data.jpa)
    // implementation(libs.spring.boot.starter.flyway)
    // implementation(libs.flyway.postgresql)
    // runtimeOnly(libs.postgresql)
}

// Unit and slice tests in src/test (*Test), full-context tests in src/integrationTest (*IT).
testing {
    suites {
        named<JvmTestSuite>("test") {
            useJUnitJupiter()
            dependencies {
                implementation(libs.spring.boot.starter.webmvc.test)
                implementation(libs.spring.boot.starter.validation.test)
                // implementation(libs.spring.boot.starter.data.jpa.test)
            }
        }
        register<JvmTestSuite>("integrationTest") {
            useJUnitJupiter()
            dependencies {
                implementation(project())
                implementation(libs.spring.boot.starter.webmvc.test)
                implementation(libs.spring.boot.starter.actuator.test)
                // Persistence (see .claude/skills/edge-cases/references/concurrency.md for the Testcontainers setup):
                // implementation(libs.spring.boot.starter.data.jpa.test)
                // implementation(libs.spring.boot.testcontainers)
                // implementation(libs.testcontainers.junit.jupiter)
                // implementation(libs.testcontainers.postgresql)
            }
            targets.all {
                testTask.configure { shouldRunAfter(tasks.test) }
            }
        }
    }
}

// Treat all compiler warnings as errors (-processing: annotation processors may not claim every annotation).
tasks.withType<JavaCompile>().configureEach {
    options.encoding = "UTF-8"
    options.compilerArgs.addAll(listOf("-Xlint:all,-processing", "-Werror"))
}

// Formatting: spotlessCheck runs in `check`; apply with ./gradlew spotlessApply.
spotless {
    java {
        target("src/**/*.java")
        googleJavaFormat()
        removeUnusedImports()
    }
}

// Coverage gate over unit + integration tests. The main() launcher class is excluded.
jacoco {
    toolVersion = libs.versions.jacoco.get()
}

val coverageMinimum = "0.80".toBigDecimal()
val allTests = listOf(tasks.test, tasks.named<Test>("integrationTest"))
val allExecData = fileTree(layout.buildDirectory.dir("jacoco")) { include("*.exec") }
val coveredClasses = sourceSets.main.map { main ->
    main.output.asFileTree.matching { exclude("**/Application.class") }
}

tasks.jacocoTestReport {
    dependsOn(allTests)
    executionData.setFrom(allExecData)
    classDirectories.setFrom(coveredClasses)
    reports {
        xml.required = true
        html.required = true
    }
}

tasks.jacocoTestCoverageVerification {
    dependsOn(allTests)
    executionData.setFrom(allExecData)
    classDirectories.setFrom(coveredClasses)
    violationRules {
        rule {
            limit {
                counter = "LINE"
                minimum = coverageMinimum
            }
        }
    }
}

tasks.check {
    dependsOn(testing.suites.named("integrationTest"))
    dependsOn(tasks.jacocoTestReport, tasks.jacocoTestCoverageVerification)
}
