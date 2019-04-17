package dk.sdu.mdsd.generator

import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.File
import java.lang.ProcessBuilder.Redirect
import java.nio.file.Path
import java.nio.file.Paths
import java.nio.file.FileSystems

class ApiKeyManager {
	
	def getKey() {
		val pb = new ProcessBuilder("python", "getkey.py")
		pb.directory(new File("C:\\Users\\Antonio\\Dropbox\\Software_Engineering\\Java Projekter\\lasr_lang\\dk.sdu.mdsd.lasr_lang.parent\\dk.sdu.mdsd.lasr_lang\\src\\dk\\sdu\\mdsd"))
		
		pb.redirectErrorStream(true)		
		val proces = pb.start()
		val reader = new BufferedReader(new InputStreamReader(proces.inputStream))
		
		return reader.readLine
	}
}