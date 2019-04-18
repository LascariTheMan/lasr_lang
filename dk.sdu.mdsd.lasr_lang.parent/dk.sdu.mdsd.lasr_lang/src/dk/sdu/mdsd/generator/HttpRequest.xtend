package dk.sdu.mdsd.generator

import com.google.gson.JsonObject
import org.apache.http.client.methods.HttpPost
import org.apache.http.impl.client.HttpClientBuilder
import com.google.gson.Gson
import org.apache.http.entity.StringEntity
import java.io.BufferedReader
import java.io.InputStreamReader
import org.apache.http.client.methods.HttpGet
import com.google.gson.JsonParser

class HttpRequest {
	
	val apiKeyManager = new ApiKeyManager
	
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
		println("Response Code : " + response.getStatusLine().getStatusCode())
		
		val reader = new BufferedReader(new InputStreamReader(response.entity.content))
		val result = new StringBuffer
		while(reader.ready) {
			println(reader.readLine)
		}
	}
	
	def createEntities() {
		
	}
	
	def getAllIntents() {
		val httpClient = HttpClientBuilder.create().build()
		val key = apiKeyManager.key
		val httpGet = new HttpGet("https://dialogflow.googleapis.com/v2/projects/speechtest-235710/agent/intents")
		httpGet.addHeader("Authorization", "Bearer " + key)
		
		val response = httpClient.execute(httpGet)
		println("Response Code : " + response.getStatusLine().getStatusCode())
		
		val reader = new BufferedReader(new InputStreamReader(response.entity.content))
		val result = new StringBuffer
		while(reader.ready) {
			result.append(reader.readLine)
		}
		
		getIdFromIntents(result)
	}
	
	def getIdFromIntents(StringBuffer result) {
		val gson = new Gson
		val result_gson = gson.fromJson(result.toString, JsonObject) 
		val result_array = result_gson.getAsJsonArray("intents")
		for (intent : result_array) {
			if (intent instanceof JsonObject) {
				val elements = intent.get("name").toString.split("/")
				val temp_id = elements.get(elements.length - 1)
				val id = temp_id.substring(0, temp_id.length - 1)
				val displayName = intent.get("displayName")
			}
		}
	}
	
	def deleteAllIntents() {
		
	}
	
	def getAllEntities() {
		
	}
	
	def deleteAllEntities() {
		
	}
}