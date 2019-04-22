package dk.sdu.mdsd.generator

import java.io.BufferedReader
import java.io.File
import java.io.InputStreamReader
import org.eclipse.core.runtime.FileLocator

class ApiKeyManager {
	
	/**
	 * Uses processbuilder to start a Python script via command line. 
	 * The getkey script will set an environment variable, which provides a path to the api key file.
	 * This environment is used by gcloud to fetch a new api key. 
	 * The print out from the python script is read through the input stream. 
	 */
	def getKey() {
		/*
		val py = new ProcessBuilder("where", "python")
		val pyproces= py.start()
		
		val reader2 = new BufferedReader(new InputStreamReader(pyproces.inputStream))
		var python_path = reader2.readLine
		 */
		val pb = new ProcessBuilder("python", "getkey.py")
		pb.directory(new File(FileLocator.resolve(class.classLoader.getResource('src/res/')).path))
		
		pb.redirectErrorStream(true)	
		val proces = pb.start()
		val reader = new BufferedReader(new InputStreamReader(proces.inputStream))
		val line = reader.readLine
			
		return line
	}
}