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
import java.util.HashMap
import dk.sdu.mdsd.lasr_lang.AbstractIntent
import dk.sdu.mdsd.lasr_lang.Parameter
import dk.sdu.mdsd.lasr_lang.List
import dk.sdu.mdsd.lasr_lang.Words

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class Lasr_langGenerator extends AbstractGenerator {
	
	val httpRequest = new HttpRequest
	val stringTypes = new StringTypes
	val abstractIntents = new HashMap<String, AbstractIntent>()
	val definedInjections = new HashMap<String, String>()
	
	/**
	 * Called when saving DSL.
	 * Generates JSON objets for each intent and EntityType
	 * Gets an updated API key for Cloud SDK
	 * Resets by deleting all intents and entitytypes excisting on the project
	 * Creates new intents and entitytypes
	 * 
	 */
	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		val gson = new GsonBuilder().setPrettyPrinting().serializeNulls().setFieldNamingPolicy(FieldNamingPolicy.UPPER_CAMEL_CASE).create()
		
		val intents = new ArrayList<JsonObject>()
		val entityTypes = new ArrayList<JsonObject>()
		val agentJSON = new JsonObject
		val apikeyManager = new ApiKeyManager
		
		resource.allContents.filter(AbstractIntent).forEach[addAbstractIntents()]
		resource.allContents.filter(Agent).forEach[generateAgentJSON(agentJSON)]
		resource.allContents.filter(Intent).forEach[generateIntentJSON(intents)]
		resource.allContents.filter(EntityType).forEach[generateEntityTypeJSON(entityTypes)]
		
		println(gson.toJson(agentJSON))
		printIntentsAndEntityTypes(intents, entityTypes, gson)
		
		
		//httpRequest.updateKey(apikeyManager.key)
		//httpRequest.reset()
		//createIntentsAndEntityTypes(intents, entityTypes, gson)
	}
	
	/**
	 * Will print all intents and entitytypes to the console
	 * 
	 * @param intents, the list of JSON objects to print
	 * @param entityTypes, the list of entitytypes to print
	 * @param gson, the gson object to handle the printout
	 */
	def printIntentsAndEntityTypes(ArrayList<JsonObject> intents, ArrayList<JsonObject> entityTypes, Gson gson) {
		for (intent : intents) {
			println(gson.toJson(intent))	
		}
		for (entityType : entityTypes) {
			println(gson.toJson(entityType))	
		}
	}
	
	/**
	 * Will create all intents and entitytypes with http requests per object in the lists
	 * 
	 * @param intents, the list of JSON objects to print
	 * @param entityTypes, the list of entitytypes to print
	 * @param gson, the gson object to handle the printout
	 */
	def createIntentsAndEntityTypes(ArrayList<JsonObject> intents, ArrayList<JsonObject> entityTypes, Gson gson) {
		for (intent : intents) {
			httpRequest.createIntent(intent, gson)
		}
		for (entityType : entityTypes) {
			httpRequest.createEntityTypes(entityType, gson)	
		}
	}
	
	def addAbstractIntents(AbstractIntent abstractIntent) {
		abstractIntents.put(abstractIntent.name, abstractIntent)
	}
	 
	/**
	 * Will generate a JSON object representing the agent defined in the DSL.
	 * 
	 * @param agent, the agent object from the DSL, which the JSON object is created of.
	 * @param obj, the JSON object that will be sent in the http request. 
	 */
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
	
	/**
	 * Will generate a JSON object representing an intent defined in the DSL.
	 * 
	 * @param intent, the agent object from the DSL, which the JSON object is created of.
	 * @param intents, the list of intents that contains all intents that must be sent with http requests 
	 */
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
				generateMessages(obj, raw_value)
			}
		}
		if (intent.toExtend !== null && abstractIntents.containsKey(intent.toExtend)) {
			addDefinedInjections(intent)
			appendAbstractIntent(intent, obj)
		}
		intents.add(obj)
	}
	
	def addDefinedInjections(Intent intent) {
		
	}
	
	def appendAbstractIntent(Intent intent, JsonObject obj) {
		val aIntent = abstractIntents.get(intent.toExtend)
		for (aValue : aIntent.values) {
			if (aValue instanceof Parameters) {
				if (obj.getAsJsonArray("parameters") === null) {
					obj.add("parameters", new JsonArray)
				} 
				val parameters = obj.getAsJsonArray("parameters")
				for (parameter: aValue.parameters) {
					parameters.add(appendParameter(aIntent, obj, parameter))
				}	
			} else if (aValue instanceof Messages) {
				handleInjections(intent, aValue)
				if (obj.getAsJsonArray("messages") === null) {
					generateMessages(obj, aValue)
				} else {
					appendMessages(obj, aValue)
				}
			}
		}
	}
	
	def handleInjections(Intent intent, Messages messages) {
		val toFind = "%"
		for (message : messages.messages) {
			var fromIndex = 0
			while ((fromIndex = message.name.indexOf(toFind, fromIndex)) != -1 ) {
	            replaceWithWord(message.name, fromIndex)
	            fromIndex++
        	}
		}
	}
	
	def replaceWithWord(String message, int fromIndex) {
		val endOfWord = message.indexOf(" ", fromIndex)
		val injection = message.substring(fromIndex+1, endOfWord)
		var newValue = message.substring(0, fromIndex) + definedInjections.get(injection)
		if (endOfWord !== -1) {	
			newValue += message.substring(endOfWord)	
		}
	}
	
	/**
	 * Will generate a JSON array of TrainingPhrases.
	 * If a sentence in the training phrase contains any entities, more properties are added. 
	 * Spaces are appended at the beginning and end of each set of words, as it is required from Dialogflow. 
	 * 
	 * @param intent, the agent object from the DSL, which the JSON object is created of.
	 * @param obj, the JSON object that is created for the whole intent. Is used to parse the final JSON array of training phrases. 
	 * @param raw_value, the data given from the DSL to build the training phrases.  
	 */
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
	
	/**
	 * Will map a entity string to a string that Dialogflow understands. 
	 * Some entities are defined beforehand in Dialogflow and these are checked. 
	 * If it doesn't match, then we'll assume it's a custom entity, and then only a '@' is appended. 
	 * 
	 * @param entity, the entity string to check.  
	 */
	def String checkTypes(String entity) {
		if (stringTypes.keywords.containsKey(entity)) {
			return stringTypes.keywords.get(entity)
		}
		return "@" + entity
	}
	
	
	/**
	 * Will generate the parameter array that is appended to the JSON intent. 
	 * 
	 * @param intent, the agent object from the DSL, which the JSON object is created of.
	 * @param obj, the JSON object that is created for the whole intent. Is used to parse the final JSON array of parameters. 
	 * @param raw_value, the data given from the DSL to build the parameters.  
	 */
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
	
	def appendParameter(AbstractIntent intent, JsonObject obj, Parameter parameter) {
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
		return parameter_json
	}
	
	/**
	 * Will generate a JSON array of messages, used for response to the user.  
	 * 
	 * @parram intent, the intent object from the DSL, which the JSON object is created of.
	 * @param object, the JSON object that is created for the whole intent. Is used to parse the final array of messages to the intent. 
	 * @param messages, the messages given from the DSL to build the response messages.  
	 */
	def generateMessages(JsonObject object, Messages messages) {
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
	
	def appendMessages(JsonObject object, Messages messages) {
		val messageArray = object.getAsJsonArray("messages").get(0) as JsonObject
		val messagesList = messageArray.getAsJsonObject("text").getAsJsonArray("text")
		for (message : messages.messages) {
			messagesList.add(message.name)
		}
	}
	
	/**
	 * Will generate a JSON objects for an entitytype 
	 * 
	 * @param entityType, the entityType object that must be parsed to a JSON object. 
	 * @param entityTypes, the array of entityTypes that must be sent with the http requests.   
	 */
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