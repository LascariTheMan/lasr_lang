package dk.sdu.mdsd.generator

import com.google.gson.JsonObject
import org.apache.http.client.methods.HttpPost
import org.apache.http.impl.client.HttpClientBuilder
import com.google.gson.Gson
import org.apache.http.entity.StringEntity
import java.io.BufferedReader
import java.io.InputStreamReader

class HttpRequest {
	
	def createIntent(JsonObject body, Gson gson) {
		val httpClient = HttpClientBuilder.create().build()
		val httpPost = new HttpPost("https://dialogflow.googleapis.com/v2/projects/speechtest-235710/agent/intents")
		httpPost.addHeader("Content-Type", "application/json")
		httpPost.addHeader("Accept", "application/json")
		httpPost.addHeader("Authorization", "Bearer ya29.c.ElrrBi6g2tv-hifkw6jL9Fo9Uh18kYuW089X-uGPIdeBUPk5e1voDQ4hMk6Uha2dOS9KQvdNJv1m1-nmfqDPazEZgwEGePoUYsk1YkXA6xU15mJK69CtpLirYr4")
		
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
	
	def getAllIntents() {
		
	}
	
	def deleteAllIntents() {
		
	}
	
	def getAllEntities() {
		
	}
	
	def deleteAllEntities() {
		
	}
}