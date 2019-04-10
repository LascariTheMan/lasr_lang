/*
 * generated by Xtext 2.16.0
 */
package dk.sdu.mdsd.generator
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import dk.sdu.mdsd.lasr_lang.Agent
import dk.sdu.mdsd.lasr_lang.AgentValue
import dk.sdu.mdsd.lasr_lang.ValueName
import dk.sdu.mdsd.lasr_lang.Intent
import dk.sdu.mdsd.lasr_lang.EntityType
import com.google.gson.Gson
import com.google.gson.JsonObject
import com.google.gson.GsonBuilder
import com.google.gson.FieldNamingPolicy

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class Lasr_langGenerator extends AbstractGenerator {
	
	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		val gson = new GsonBuilder().setPrettyPrinting().serializeNulls().setFieldNamingPolicy(FieldNamingPolicy.UPPER_CAMEL_CASE).create()
		val obj = new JsonObject
		resource.allContents.filter(Agent).forEach[generateAgentJSON(obj)]
		println(gson.toJson(obj))
		//resource.allContents.filter(Intent).forEach[generateIntentJSON]
		//resource.allContents.filter(EntityType).forEach[generateEntityTypeJSON]
	}
	 
	def generateAgentJSON(Agent agent, JsonObject obj) {
		var key = new String()
		var value = new Object()
	
		for(m : agent.values) {
			key = m.aa.toString()
			if(m.value.bool === null) {
				value = m.value.v.name
				obj.addProperty(key, value.toString)
			} else {
				value = Boolean.parseBoolean(m.value.bool)
				obj.addProperty(key, value.toString)
			}	
		}
	}
	
	def generateIntentJSON() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
	
	def generateEntityTypeJSON() {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
}