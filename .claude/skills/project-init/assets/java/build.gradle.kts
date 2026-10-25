plugins {
    java
    jacoco
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
}

// Unit tests in src/test (*Test), integration tests in src/integrationTest (*IT).
testing {
    suites {
        named<JvmTestSuite>("test") {
            useJUnitJupiter(libs.versions.junit)
            dependencies {
                implementation(libs.assertj)
            }
        }
        register<JvmTestSuite>("integrationTest") {
            useJUnitJupiter(libs.versions.junit)
            dependencies {
                implementation(project())
                implementation(libs.assertj)
            }
            targets.all {
                testTask.configure { shouldRunAfter(tasks.test) }
            }
        }
    }
}

// Treat all compiler warnings as errors.
tasks.withType<JavaCompile>().configureEach {
    options.encoding = "UTF-8"
    options.compilerArgs.addAll(listOf("-Xlint:all", "-Werror"))
}

// Formatting: spotlessCheck runs in `check`; apply with ./gradlew spotlessApply.
spotless {
    java {
        target("src/**/*.java")
        googleJavaFormat()
        removeUnusedImports()
    }
}

// Coverage gate over unit + integration tests.
jacoco {
    toolVersion = libs.versions.jacoco.get()
}

val coverageMinimum = "0.80".toBigDecimal()
val allTests = listOf(tasks.test, tasks.named<Test>("integrationTest"))
val allExecData = fileTree(layout.buildDirectory.dir("jacoco")) { include("*.exec") }

tasks.jacocoTestReport {
    dependsOn(allTests)
    executionData.setFrom(allExecData)
    reports {
        xml.required = true
        html.required = true
    }
}

tasks.jacocoTestCoverageVerification {
    dependsOn(allTests)
    executionData.setFrom(allExecData)
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
