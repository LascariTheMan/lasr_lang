package dk.sdu.mdsd.generator

import java.io.BufferedReader
import java.io.File
import java.io.InputStreamReader
import org.eclipse.core.runtime.FileLocator

class ApiKeyManager {
	
	def getKey() {
		/*
		val py = new ProcessBuilder("where", "python")
		val pyproces= py.start()
		
		val reader2 = new BufferedReader(new InputStreamReader(pyproces.inputStream))
		var python_path = reader2.readLine
		 */
		val pb = new ProcessBuilder("py", "getkey.py")
		pb.directory(new File(FileLocator.resolve(class.classLoader.getResource('src/res/')).path))
		
		pb.redirectErrorStream(true)	
		val proces = pb.start()
		val reader = new BufferedReader(new InputStreamReader(proces.inputStream))
		val line = reader.readLine
			
		return line
	}
}