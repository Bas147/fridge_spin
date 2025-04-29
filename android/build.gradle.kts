// Top-level build file where you can add configuration options common to all sub-projects/modules.

buildscript {
    // เปลี่ยนเวอร์ชัน Kotlin ให้ตรงกับ plugin ในไฟล์ settings.gradle.kts
    val kotlin_version = "2.0.0"
    
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Add the Google services Gradle plugin
        classpath("com.google.gms:google-services:4.4.0")
        // เพิ่ม Kotlin Gradle Plugin
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version")
    }
}

// เปลี่ยนเป็นการกำหนดตำแหน่ง build directory แบบเดียว
rootProject.buildDir = File(rootProject.projectDir, "../build")

// ลบส่วนที่กำหนด buildDir ซ้ำซ้อน
// val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
// rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    // ใช้ buildDir จาก rootProject
    project.buildDir = File(rootProject.buildDir, project.name)
    // แทนการกำหนดด้วย layout.buildDirectory
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
