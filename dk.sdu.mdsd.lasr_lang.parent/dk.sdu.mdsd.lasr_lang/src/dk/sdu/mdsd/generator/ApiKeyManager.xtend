package dk.sdu.mdsd.generator

import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.File
import java.lang.ProcessBuilder.Redirect
import java.nio.file.Path
import java.nio.file.Paths
import java.nio.file.FileSystems
import org.eclipse.core.runtime.FileLocator

class ApiKeyManager {
	
	def getKey() {
		val pb = new ProcessBuilder("python", "getkey.py")
		pb.directory(new File(FileLocator.resolve(class.classLoader.getResource('src/res/')).path))
		
		pb.redirectErrorStream(true)	
		val proces = pb.start()
		val reader = new BufferedReader(new InputStreamReader(proces.inputStream))
		val line = reader.readLine
		
		return line
	}
}