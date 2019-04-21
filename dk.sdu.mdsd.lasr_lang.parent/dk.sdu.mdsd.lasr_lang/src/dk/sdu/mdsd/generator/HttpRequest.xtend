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
	
	var key = new String
	val intents_to_keep = new ArrayList<String>(Arrays.asList("Default Welcome Intent", "Default Fallback Intent"))
	
	def updateKey(String key) {
		this.key = key
	}
	
	def reset() {
		getAllIds("intents")
		getAllIds("entityTypes")
	}
	
	def getAllIds(String type) {
		val httpClient = HttpClientBuilder.create().build()
		val httpGet = new HttpGet("https://dialogflow.googleapis.com/v2/projects/speechtest-235710/agent/" + type)
		httpGet.addHeader("Authorization", "Bearer " + key)
		
		val response = httpClient.execute(httpGet)
		println("Response Code for getting all " + type + ": " + response.getStatusLine().getStatusCode())
		
		val reader = new BufferedReader(new InputStreamReader(response.entity.content))
		val result = new StringBuffer
		while(reader.ready) {
			result.append(reader.readLine)
		}
		findIdsToDelete(result, type)
	}
	
	def findIdsToDelete(StringBuffer result, String type) {
		val gson = new Gson
		val ids_to_delete = new ArrayList<String>()
		val result_gson = gson.fromJson(result.toString, JsonObject) 
		val result_array = result_gson.getAsJsonArray(type)
		try {
			for (obj : result_array) {
				if (obj instanceof JsonObject) {
					val path = removeQuotation(obj.get("name").toString).split("/")
					val id = path.get(path.length - 1)
					val displayName = removeQuotation(obj.get("displayName").toString)
					
					if (!intents_to_keep.contains(displayName)) {
						ids_to_delete.add(id)
					}
				}
			}
			deleteAllIds(ids_to_delete, type)
		} catch(NullPointerException e) {
			
		}
	}
	
	def removeQuotation(String element) {
		val without_quotation = element.substring(1, element.length - 1)
		return without_quotation
	}
	
	def deleteAllIds(ArrayList<String> ids, String type) {
		for (id : ids) {
			val httpClient = HttpClientBuilder.create().build()
			val httpDelete = new HttpDelete("https://dialogflow.googleapis.com/v2/projects/speechtest-235710/agent/" + type + "/" + id)
			httpDelete.addHeader("Authorization", "Bearer " + key)
			
			val response = httpClient.execute(httpDelete)
			println("Response Code for deleting " + id + ": " + response.getStatusLine().getStatusCode())
		}
	}
	
	def createIntent(JsonObject body, Gson gson) {
		val httpClient = HttpClientBuilder.create().build()
		val httpPost = new HttpPost("https://dialogflow.googleapis.com/v2/projects/speechtest-235710/agent/intents")
		httpPost.addHeader("Content-Type", "application/json")
		httpPost.addHeader("Accept", "application/json")
		httpPost.addHeader("Authorization", "Bearer " + key)
		
		val json_string = new StringEntity(gson.toJson(body))
		httpPost.entity = json_string
		
		val response = httpClient.execute(httpPost)
		println("Response Code for creating intent " + body.get("displayName") + ": " + response.getStatusLine().getStatusCode())
	}
	
	def createEntityTypes(JsonObject body, Gson gson) {
		val httpClient = HttpClientBuilder.create().build()
		val httpPost = new HttpPost("https://dialogflow.googleapis.com/v2/projects/speechtest-235710/agent/entityTypes")
		httpPost.addHeader("Content-Type", "application/json")
		httpPost.addHeader("Accept", "application/json")
		httpPost.addHeader("Authorization", "Bearer " + key)
		
		val json_string = new StringEntity(gson.toJson(body))
		httpPost.entity = json_string
		
		val response = httpClient.execute(httpPost)
		println("Response Code for creating EntityType " + body.get("displayName") + ": " + response.getStatusLine().getStatusCode())
	}
}