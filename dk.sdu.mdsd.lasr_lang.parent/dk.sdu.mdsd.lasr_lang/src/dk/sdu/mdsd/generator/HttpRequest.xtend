package dk.sdu.mdsd.generator

import com.google.gson.Gson
import com.google.gson.JsonObject
import java.io.BufferedReader
import java.io.InputStreamReader
import java.util.ArrayList
import java.util.Arrays
import org.apache.http.client.methods.HttpDelete
import org.apache.http.client.methods.HttpGet
import org.apache.http.client.methods.HttpPost
import org.apache.http.entity.StringEntity
import org.apache.http.impl.client.HttpClientBuilder

class HttpRequest {
	
	val apiKeyManager = new ApiKeyManager
	val intents_to_keep = new ArrayList<String>(Arrays.asList("Default Welcome Intent", "Default Fallback Intent"))
	
	def createIntent(JsonObject body, Gson gson) {
		val httpClient = HttpClientBuilder.create().build()
		val key = apiKeyManager.key
		val httpPost = new HttpPost("https://dialogflow.googleapis.com/v2/projects/speechtest-235710/agent/intents")
		httpPost.addHeader("Content-Type", "application/json")
		httpPost.addHeader("Accept", "application/json")
		httpPost.addHeader("Authorization", "Bearer " + key)
		
		val json_string = new StringEntity(gson.toJson(body))
		httpPost.entity = json_string
		
		val response = httpClient.execute(httpPost)
		println("Response Code for creating intent " + body.get("displayName") + ": " + response.getStatusLine().getStatusCode())
	}
	
	def getAllIntents() {
		val httpClient = HttpClientBuilder.create().build()
		val key = apiKeyManager.key
		val httpGet = new HttpGet("https://dialogflow.googleapis.com/v2/projects/speechtest-235710/agent/intents")
		httpGet.addHeader("Authorization", "Bearer " + key)
		
		val response = httpClient.execute(httpGet)
		println("Response Code for getting all intents: " + response.getStatusLine().getStatusCode())
		
		val reader = new BufferedReader(new InputStreamReader(response.entity.content))
		val result = new StringBuffer
		while(reader.ready) {
			result.append(reader.readLine)
		}
		
		getIdFromIntents(result, key)
	}
	
	def getIdFromIntents(StringBuffer result, String key) {
		val gson = new Gson
		val intents_to_delete = new ArrayList<String>()
		val result_gson = gson.fromJson(result.toString, JsonObject) 
		val result_array = result_gson.getAsJsonArray("intents")
		for (intent : result_array) {
			if (intent instanceof JsonObject) {
				val intent_path = removeQuotation(intent.get("name").toString).split("/")
				val id = intent_path.get(intent_path.length - 1)
				val displayName = removeQuotation(intent.get("displayName").toString)
				
				if (!intents_to_keep.contains(displayName)) {
					intents_to_delete.add(id)
				}
			}
		}
		deleteAllIntents(intents_to_delete, key)
	}
	
	def removeQuotation(String element) {
		val without_quotation = element.substring(1, element.length - 1)
		return without_quotation
	}
	
	def deleteAllIntents(ArrayList<String> intents, String key) {
		for (intent : intents) {
			val httpClient = HttpClientBuilder.create().build()
			val httpDelete = new HttpDelete("https://dialogflow.googleapis.com/v2/projects/speechtest-235710/agent/intents/" + intent)
			httpDelete.addHeader("Authorization", "Bearer " + key)
			
			val response = httpClient.execute(httpDelete)
			println("Response Code for deleting " + intent + ": " + response.getStatusLine().getStatusCode())
		}
	}
	
	def createEntities() {
		
	}
	
	def getAllEntities() {
		
	}
	
	def deleteAllEntities() {
		
	}
}