plugins {
    // Downloads the JDK from build.gradle.kts's toolchain if it isn't installed locally.
    id("org.gradle.toolchains.foojay-resolver-convention") version "1.0.0"
}

rootProject.name = "app"
