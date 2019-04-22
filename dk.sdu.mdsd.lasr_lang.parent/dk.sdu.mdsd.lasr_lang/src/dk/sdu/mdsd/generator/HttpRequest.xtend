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
import org.apache.http.impl.client.BasicResponseHandler
import org.apache.http.util.EntityUtils
import org.apache.http.HttpResponse

class HttpRequest {
	
	var key = new String
	val intents_to_keep = new ArrayList<String>(Arrays.asList("Default Welcome Intent", "Default Fallback Intent"))
	
	/**
	 * Update the api key from the ApiKeyManager.
	 * 
	 * @param key, the key returned from the apikeymanager.
	 */
	def updateKey(String key) {
		this.key = key
	}
	
	/**
	 * Will initialize the reset of intents and entityTypes
	 */
	def reset() {
		getAllIds("intents")
		getAllIds("entityTypes")
	}
	
	/**
	 * Will create a GET request to get all ID's from Dialogflow.
	 * All ID's are appended to a stringbuffer
	 * 
	 * @param type, is either "intents" or "entityTypes" given from the reset() function.
	 */
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
	
	/**
	 * Will find all ID's that should be deleted. 
	 * Some intents want to be kept (see the 'intents_to_keep' variable at the top)
	 * If no ID's are found a nullpointer is catched and will be printed to the user. 
	 * 
	 * @param result, the result from the search of ID's
	 * @param type, the type (either 'intent' or 'entitytype') given from the reset() function.
	 */
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
			println("NO INTENTS TO DELETE FOUND - PROCEEDING TO CREATE STAGE")
		}
	}
	
	/**
	 * When parsing the response, the quotation marks are removed.
	 * 
	 * @param element, the string element that contains quotes. 
	 */
	def removeQuotation(String element) {
		val without_quotation = element.substring(1, element.length - 1)
		return without_quotation
	}
	
	/**
	 * Will create a delete http request for each ID found. 
	 * 
	 * @param ids, the list of ID's to delete.
	 * @param type, the type (either 'intent' or 'entitytype') given from the reset() function.
	 */
	def deleteAllIds(ArrayList<String> ids, String type) {
		for (id : ids) {
			val httpClient = HttpClientBuilder.create().build()
			val httpDelete = new HttpDelete("https://dialogflow.googleapis.com/v2/projects/speechtest-235710/agent/" + type + "/" + id)
			httpDelete.addHeader("Authorization", "Bearer " + key)
			
			val response = httpClient.execute(httpDelete)
			println("Response Code for deleting " + id + ": " + response.getStatusLine().getStatusCode())
			if (response.getStatusLine().getStatusCode() !== 200){
				printErrorMessage(response)
			}
		}
	}
	
	/**
	 * Will create a http post request to create a new intent. 
	 * 
	 * @param body, the generated JSON that represents the intent
	 * @param gson, the gson object to parse from Java object to JSON format. 
	 */
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
	
	/**
	 * Will create a http post request to create a new entityType. 
	 * 
	 * @param body, the generated JSON that represents the entityType
	 * @param gson, the gson object to parse from Java object to JSON format. 
	 */
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
		if (response.getStatusLine().getStatusCode() !== 200){
			printErrorMessage(response)
		}
	}
	
	/**
	 * If a http request doesn't return status code 200, this function is used to
	 * print the error message given from Dialogflow. 
	 * 
	 * @param response, the HTTPReponse object given from sending the http request. 
	 */
	def printErrorMessage(HttpResponse response) {
		println(response.statusLine.reasonPhrase)
		val entity = response.getEntity();
		val responseString = EntityUtils.toString(entity, "UTF-8")
		println(responseString)
	}
}