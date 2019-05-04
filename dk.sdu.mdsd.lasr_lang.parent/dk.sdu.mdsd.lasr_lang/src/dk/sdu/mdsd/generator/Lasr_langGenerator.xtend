/*
 * generated by Xtext 2.16.0
 */
package dk.sdu.mdsd.generator

import com.google.gson.FieldNamingPolicy
import com.google.gson.GsonBuilder
import com.google.gson.JsonArray
import com.google.gson.JsonObject
import dk.sdu.mdsd.lasr_lang.Agent
import dk.sdu.mdsd.lasr_lang.Intent
import dk.sdu.mdsd.lasr_lang.KeyValue
import dk.sdu.mdsd.lasr_lang.Parameters
import dk.sdu.mdsd.lasr_lang.TrainingPhrases
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import dk.sdu.mdsd.lasr_lang.EntityType
import java.util.ArrayList
import com.google.gson.Gson
import dk.sdu.mdsd.lasr_lang.Messages
import dk.sdu.mdsd.lasr_lang.AbstractIntent
import dk.sdu.mdsd.lasr_lang.AbstractTrainingPhrases
import dk.sdu.mdsd.lasr_lang.AbstractParameters
import dk.sdu.mdsd.lasr_lang.AbstractMessages

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class Lasr_langGenerator extends AbstractGenerator {
	
	val httpRequest = new HttpRequest
	val stringTypes = new StringTypes
	
	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		val gson = new GsonBuilder().setPrettyPrinting().serializeNulls().setFieldNamingPolicy(FieldNamingPolicy.UPPER_CAMEL_CASE).create()
		
		val intents = new ArrayList<JsonObject>()
		val abstractIntents = new ArrayList<JsonObject>()
		val entityTypes = new ArrayList<JsonObject>()
		val agentJSON = new JsonObject
		val apikeyManager = new ApiKeyManager
		
		resource.allContents.filter(Agent).forEach[generateAgentJSON(agentJSON)]
		resource.allContents.filter(Intent).forEach[generateIntentJSON(intents)]
		resource.allContents.filter(AbstractIntent).forEach[generateAbstractIntentTypeJSON(abstractIntents)]
		resource.allContents.filter(EntityType).forEach[generateEntityTypeJSON(entityTypes)]
		
		
		printIntentsAndEntityTypes(intents, entityTypes, abstractIntents, gson)
		
		
		httpRequest.updateKey(apikeyManager.key)
		httpRequest.reset()
		createIntentsAndEntityTypes(intents, entityTypes, gson)
	}
	
	
	def printIntentsAndEntityTypes(ArrayList<JsonObject> intents, ArrayList<JsonObject> entityTypes, ArrayList<JsonObject> abstractIntents , Gson gson) {
		/*for (intent : intents) {
			println(gson.toJson(intent))	
		}*/
		for (abstractIntent : abstractIntents) {
			println(gson.toJson(abstractIntent))	
		}
		/*for (entityType : entityTypes) {
			println(gson.toJson(entityType))	
		}*/
	}
	
	def createIntentsAndEntityTypes(ArrayList<JsonObject> intents, ArrayList<JsonObject> entityTypes, Gson gson) {
		for (intent : intents) {
			httpRequest.createIntent(intent, gson)
		}
		for (entityType : entityTypes) {
			httpRequest.createEntityTypes(entityType, gson)	
		}
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
	
	def generateIntentJSON(Intent intent, ArrayList<JsonObject> intents) {
		val obj = new JsonObject
		var key = new String()
		var value = new Object()
		obj.addProperty("displayName", intent.name)
		for (i : intent.values) {
			val raw_value = i.iv
			if (raw_value instanceof KeyValue) {
				key = raw_value.v 
				value = raw_value.name
				obj.addProperty(key, value.toString)
			} else if (raw_value instanceof TrainingPhrases) {
				generateTrainingPhrases(intent, obj, raw_value)			
			} else if (raw_value instanceof Parameters) {
				generateParameters(intent, obj, raw_value)
			} else if (raw_value instanceof Messages) {
				generateMessages(intent, obj, raw_value)
			}
		}
		intents.add(obj)
	}
	
	def generateAbstractIntentTypeJSON(AbstractIntent abstractIntent, ArrayList<JsonObject> abstractIntents) {
		val obj = new JsonObject
		obj.addProperty("displayName", abstractIntent.name)
		var key = new String()
		var value = new Object()
		for (i : abstractIntent.abstractValues) {
			val raw_value = i.aiv
			if (raw_value instanceof KeyValue) {
				key = raw_value.v 
				value = raw_value.name
				obj.addProperty(key, value.toString)
            } else if (raw_value instanceof AbstractTrainingPhrases) {
				generateTrainingPhrases(abstractIntent, obj, raw_value)			
			} else if (raw_value instanceof AbstractParameters) {
				generateParameters(abstractIntent, obj, raw_value)
			} else if (raw_value instanceof AbstractMessages) {
				generateMessages(abstractIntent, obj, raw_value)
			}
		}
		abstractIntents.add(obj)
	}
	
	def generateTrainingPhrases(Intent intent, JsonObject obj, TrainingPhrases raw_value) {
		val key = "trainingPhrases"
		val values = new JsonArray
		for (phrase : raw_value.phrases) {
			val entry_phrase = new JsonObject
			val parts_key = "parts"
			val parts = new JsonArray
			for (part : phrase.sentences) {
				val json_part = new JsonObject
				val part_text_key = "text"
				var part_text_value = new String()
				if (part.entity !== null) {
					val entity_type_value = checkTypes(part.entity)
					json_part.addProperty("entityType", entity_type_value)
					json_part.addProperty("alias", part.entity)
					json_part.addProperty("userDefined", "true")
				}
				for (word : part.words) {
					part_text_value = " " + word.name + " "
				}
				json_part.addProperty(part_text_key, part_text_value)
				parts.add(json_part)
			}
			entry_phrase.add(parts_key, parts)
			values.add(entry_phrase)
		}
		obj.add(key, values)
	}
	
	def generateTrainingPhrases(AbstractIntent abstractIntent, JsonObject obj, AbstractTrainingPhrases raw_value) {
		val key = "trainingPhrases"
		val values = new JsonArray
		for (phrase : raw_value.abstractPhrases) {
			val entry_phrase = new JsonObject
			val parts_key = "parts"
			val parts = new JsonArray
			for (part : phrase.sentences) {
				val json_part = new JsonObject
				val part_text_key = "text"
				var part_text_value = new String()
				if (part.entity !== null) {
					val entity_type_value = checkTypes(part.entity)
					json_part.addProperty("entityType", entity_type_value)
					json_part.addProperty("alias", part.entity)
					json_part.addProperty("userDefined", "true")
				}
				for (word : part.abstractWords) {
					part_text_value = " " + word.name + " "
				}
				json_part.addProperty(part_text_key, part_text_value)
				parts.add(json_part)
			}
			entry_phrase.add(parts_key, parts)
			values.add(entry_phrase)
		}
		obj.add(key, values)
	}  
	
	def String checkTypes(String entity) {
		if (stringTypes.keywords.containsKey(entity)) {
			return stringTypes.keywords.get(entity)
		}
		return "@" + entity
	}
	
	def generateParameters(Intent intent, JsonObject obj, Parameters raw_value) {
		val key = raw_value.v
		val values = new JsonArray
		for (parameter : raw_value.parameters) {
			val parameter_json = new JsonObject
			if (parameter.req !== null) {
				parameter_json.addProperty("mandatory", true)	
			} else {
				parameter_json.addProperty("mandatory", false)
			}
			parameter_json.addProperty("displayName", parameter.name)
			parameter_json.addProperty("entityTypeDisplayName", checkTypes(parameter.type))
			parameter_json.addProperty("isList", false)
			val prompt_key = "prompts"
			val prompt_values = new JsonArray
			for (prompt : parameter.prompts) {
				for (word : prompt.words) {
					prompt_values.add(word.name)
				}
			}
			parameter_json.add(prompt_key, prompt_values)
			values.add(parameter_json)
		}
		obj.add(key, values)
	}
	
	def generateParameters(AbstractIntent abstractIntent, JsonObject obj, AbstractParameters raw_value) {
		val key = raw_value.v
		val values = new JsonArray
		for (parameter : raw_value.abstractParameters) {
			val parameter_json = new JsonObject
			if (parameter.req !== null) {
				parameter_json.addProperty("mandatory", true)	
			} else {
				parameter_json.addProperty("mandatory", false)
			}
			parameter_json.addProperty("displayName", parameter.name)
			parameter_json.addProperty("entityTypeDisplayName", checkTypes(parameter.type))
			parameter_json.addProperty("isList", false)
			val prompt_key = "prompts"
			val prompt_values = new JsonArray
			for (prompt : parameter.abstractPrompts) {
				for (word : prompt.abstractWords) {
					prompt_values.add(word.name)
				}
			}
			parameter_json.add(prompt_key, prompt_values)
			values.add(parameter_json)
		}
		obj.add(key, values)
	}
	
	def generateMessages(Intent intent, JsonObject object, Messages messages) {
		val key = "messages"
		val value = new JsonArray
		val text_value = new JsonObject
		val text_array = new JsonObject
		val array_of_messages = new JsonArray
		
		for (message : messages.messages) {
			array_of_messages.add(message.name)
		}
		
		text_array.add("text", array_of_messages)
		text_value.add("text", text_array)
		value.add(text_value)
		object.add(key, value)
	}
	
	def generateMessages(AbstractIntent abstractIntent, JsonObject object, AbstractMessages abstractMessages) {
		val key = "messages"
		val value = new JsonArray
		val text_value = new JsonObject
		val text_array = new JsonObject
		val array_of_abstractMessages = new JsonArray
		
		for (aMessage : abstractMessages.abstractMessages) {
			array_of_abstractMessages.add(aMessage.name)
		}
		
		text_array.add("text", array_of_abstractMessages)
		text_value.add("text", text_array)
		value.add(text_value)
		object.add(key, value)
	}
	
	def generateEntityTypeJSON(EntityType entityType, ArrayList<JsonObject> entityTypes) {
		val obj = new JsonObject
		obj.addProperty("displayName", entityType.name)
		obj.addProperty("kind", "KIND_MAP")
		if (entityType.exp == "true") {
			obj.addProperty("autoExpansionMode", "AUTO_EXPANSION_MODE_DEFAULT")
		} else {
			obj.addProperty("autoExpansionMode", "AUTO_EXPANSION_MODE_UNSPECIFIED")
		}
		val key = "entities"
		val value = new JsonArray
		for (entities : entityType.entities) {
			for (entity : entities.entity) {
				val entry = new JsonObject
				entry.addProperty("value", entity.value)
				val entity_key = "synonyms"
				val entity_value = new JsonArray
				for (synonym : entity.syn) {
					entity_value.add(synonym.syn)
				}
				entry.add(entity_key, entity_value)
				value.add(entry)
			}
		}
		obj.add(key, value)
		entityTypes.add(obj)
	}
}