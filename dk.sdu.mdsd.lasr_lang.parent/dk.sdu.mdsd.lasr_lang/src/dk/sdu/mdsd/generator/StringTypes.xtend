package dk.sdu.mdsd.generator

import java.util.Map
import java.util.HashMap

class StringTypes {
	
	var keywords = createMap()

	def static Map<String, String> createMap() {
	    val mapToReturn = new HashMap<String,String>()
	    mapToReturn.put("givenName", "@sys.given-name")
	    mapToReturn.put("timePeriod", "@sys.time-period")
	    mapToReturn.put("date", "@sys.date")
	    mapToReturn.put("age", "@sys.age")
	    mapToReturn.put("time", "@sys.time")
	    mapToReturn.put("datePeriod", "@sys.date-period")
	    mapToReturn.put("phoneNumber", "@sys.phone-number")
	    mapToReturn.put("number", "@sys.number")
	    mapToReturn.put("location", "@sys.location")
	    mapToReturn.put("country", "@sys.geo-country")
	    mapToReturn.put("capital", "@sys.geo-capital")
	    return mapToReturn;
	}
	
	def getKeywords() {
		return keywords
	}
}