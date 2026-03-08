allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    // Parche para librerías antiguas sin namespace (como bluetooth)
    afterEvaluate {
        if (project.hasProperty("android")) {
            val android = project.extensions.findByName("android")
            try {
                val getNamespace = android?.javaClass?.getMethod("getNamespace")
                val namespace = getNamespace?.invoke(android)
                if (namespace == null) {
                    val setNamespace = android?.javaClass?.getMethod("setNamespace", String::class.java)
                    setNamespace?.invoke(android, "temp.namespace.${project.name}")
                }
            } catch (e: Exception) {
                // Si falla por reflexión, al menos intentamos seguir
            }
        }
    }
}



tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
subprojects {
    afterEvaluate {
        // Solo aplicamos la cirugía a las librerías externas, no a tu app
        if (project.name != "app") {
            val removePackageAttr = tasks.register("removePackageAttributeFromManifest") {
                val manifestFile = file("src/main/AndroidManifest.xml")
                if (manifestFile.exists()) {
                    doLast {
                        val content = manifestFile.readText()
                        if (content.contains("package=")) {
                            val updatedContent = content.replace(Regex("""package="[^"]*""""), "")
                            manifestFile.writeText(updatedContent)
                            println("Cirugía exitosa: Atributo 'package' eliminado de ${project.name}")
                        }
                    }
                }
            }

            // Usamos whenTaskAdded para esperar a que Gradle cree las tareas de manifest
            tasks.whenTaskAdded {
                if (name == "processDebugManifest" || name == "processReleaseManifest") {
                    dependsOn(removePackageAttr)
                }
            }
        }
    }
}