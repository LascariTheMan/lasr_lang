/*
 * generated by Xtext 2.16.0
 */
package dk.sdu.mdsd.validation

import dk.sdu.mdsd.lasr_lang.Agent
import dk.sdu.mdsd.lasr_lang.AgentValue
import dk.sdu.mdsd.lasr_lang.Intent
import dk.sdu.mdsd.lasr_lang.IntentRequired
import dk.sdu.mdsd.lasr_lang.IntentValue
import dk.sdu.mdsd.lasr_lang.Parameter
import dk.sdu.mdsd.lasr_lang.Prompt
import dk.sdu.mdsd.lasr_lang.Sentence
import dk.sdu.mdsd.lasr_lang.Lasr_langPackage
import dk.sdu.mdsd.lasr_lang.Words
import java.util.ArrayList
import org.eclipse.xtext.validation.Check
import java.util.Map
import java.util.HashMap
import java.util.Set
import java.util.HashSet

/**
 * This class contains custom validation rules. 
 *
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class Lasr_langValidator extends AbstractLasr_langValidator {
	
	public static val INVALID_NAME = 'invalidName'
	public static val MISSING_AGENT_PARENT = 'missingAgentParent'
	public static val MISSING_AGENT_DISPLAYNAME = 'missingAgentDisplayName'
	public static val MISSING_AGENT_DEFAULTLANGUAGECODE = 'missingAgentDefaultLanguageCode'
	public static val MISSING_AGENT_TIMEZONE = 'missingAgentTimezone'
	public static val MISSING_AGENT_ENABLELOGGING = 'missingAgentEnableLogging'
	public static val TYPEMISMATCH_AGENT_PARENT = 'typeMismatchAgentEnableLogging'
	public static val TYPEMISMATCH_AGENT_DISPLAYNAME = 'typeMismatchAgentEnableLogging'
	public static val TYPEMISMATCH_AGENT_DEFAULTLANGUAGECODE = 'typeMismatchAgentEnableLogging'
	public static val TYPEMISMATCH_AGENT_TIMEZONE = 'typeMismatchAgentEnableLogging'
	public static val TYPEMISMATCH_AGENT_ENABLELOGGING = 'typeMismatchAgentEnableLogging'
	public static val ONLY_ONE_AGENT_ALLOWED = 'onlyOneAgentInstanceIsAllowed'
	public static val IF_REQUIRED_PARAM_THEN_PROMPT = 'requiredParameterMustContainPrompt'
	public static val PROMPT_STRING_SHOULD_NOT_BE_EMPTY = 'promptStringShouldNotBeEmpty'
	public static val PHRASE_STRING_SHOULD_NOT_BE_EMPTY = 'phraseStringShouldNotBeEmpty'
	public static val MISSING_INTENT_DISPLAYNAME = 'missingIntentDisplayName'
	// MIssing validation:
	// Agent and Intent: validate that only 1 of each parameter has been written.
	
	@Check
	def checkIfAgentParamsAreMissing(Agent agent) {
		checkAgentParams(agent)
	}
	
	@Check
	def checkIfAgentParamsAreUpper(AgentValue av) {
		if (!Character.isUpperCase(av.value.v.name.charAt(0))) {
        warning('Agent attributes should start with a capital', 
                Lasr_langPackage.Literals.AGENT_VALUE__VALUE,
                -1,
                INVALID_NAME)
    }
	}
	
	@Check
	def checkIfAgentParamsAreAllowed(AgentValue agentVal) {
		if(agentVal.value.bool == 'true' || agentVal.value.bool == 'false') {
			checkAgentParams(agentVal)
		}
	}
	
	@Check
	def checkAgentMultipleSameParams(AgentValue agentVal) {
		checkAgentMultipleParams(agentVal)
	}

	@Check
	def ifRequiredParameterThenPrompts(Parameter param){
		if(param.req == "required" && param.prompts.isEmpty()) {
			error("You must create at least one prompt if the parameter is: "+ param.req.toString(),
				Lasr_langPackage.Literals.PARAMETER__REQ,
				IF_REQUIRED_PARAM_THEN_PROMPT)
		}
	}
	
	@Check
	def promptStringShouldNotBeEmpty(Prompt p) {
		for(Words w : p.words) {			
			if("".equals(w.name)) {
				warning("A prompt should not be empty",
					Lasr_langPackage.Literals.PROMPT__WORDS,
					PROMPT_STRING_SHOULD_NOT_BE_EMPTY
				)
			}
		}
	}
	
	@Check
	def phraseStringShouldNotBeEmpty(Sentence s) {
		for(Words w : s.words) {			
			if("".equals(w.name)) {
				warning("A phrase should not be empty",
					Lasr_langPackage.Literals.SENTENCE__WORDS,
					PHRASE_STRING_SHOULD_NOT_BE_EMPTY
				)
			}
		}
	}
	
	@Check
	def checkIntentDisplayNameIsNotNull(Intent i) {
		checkIntentParams(i);
	}
	
	@Check
	def checkIntentHasOnlyOneOfEachParam(Intent intent) {
		val intentValSet = newHashSet
		for(var i = 0 ; i < intent.values.length ; i++) {
			if(!intentValSet.add(intent.values.get(i).va)){
				error("duplicate entry", intent.values.get(i), null, "code")
			}
		}		
	}
	
	@Check
	def checkAgentHasOnlyOneOfEachParam(Agent a) {
		val agentValSet = newHashSet
		for(var i = 0 ; i < a.values.length ; i++) {
			if(!agentValSet.add(a.values.get(i).aa)){
				error("duplicate entry", a.values.get(i), null, "code")
			}
		}		
	}
	
	def checkAgentParams(AgentValue agentVal) {
		if(agentVal.aa == "parent" && (agentVal.value.bool == 'true' || agentVal.value.bool == 'false')) {
			error('Type mismatch: '+ agentVal.aa + ' cannot be set to ' +agentVal.value.bool, 
				Lasr_langPackage.Literals.AGENT_VALUE__VALUE,
				TYPEMISMATCH_AGENT_PARENT)
		}
		if(agentVal.aa == "displayName" && (agentVal.value.bool == 'true' || agentVal.value.bool == 'false')) {
			error('Type mismatch: '+ agentVal.aa + ' cannot be set to ' +agentVal.value.bool, 
				Lasr_langPackage.Literals.AGENT_VALUE__VALUE,
				TYPEMISMATCH_AGENT_DISPLAYNAME)
		}
		if(agentVal.aa == "defaultLanguageCode" && (agentVal.value.bool == 'true' || agentVal.value.bool == 'false')) {
			error('Type mismatch: '+ agentVal.aa + ' cannot be set to ' +agentVal.value.bool, 
				Lasr_langPackage.Literals.AGENT_VALUE__VALUE,
				TYPEMISMATCH_AGENT_DEFAULTLANGUAGECODE)
		}
		if(agentVal.aa == "timezone" && (agentVal.value.bool == 'true' || agentVal.value.bool == 'false')) {
			error('Type mismatch: '+ agentVal.aa + ' cannot be set to ' +agentVal.value.bool, 
				Lasr_langPackage.Literals.AGENT_VALUE__VALUE,
				TYPEMISMATCH_AGENT_TIMEZONE)
		}
		if(agentVal.aa == "enableLogging" && (agentVal.value.v.name !== 'true' || agentVal.value.v.name !== 'false')) {
			error('Type mismatch:  '+ agentVal.aa + ' cannot be set to ' +agentVal.value.v.name.class.typeName, 
				Lasr_langPackage.Literals.AGENT_VALUE__VALUE,
				TYPEMISMATCH_AGENT_ENABLELOGGING)
		}
	}
	
	def checkAgentMultipleParams(AgentValue agentVal) {
		if(agentVal.aa == "parent" && (agentVal.value.bool == 'true' || agentVal.value.bool == 'false')) {
			error('Type mismatch: '+ agentVal.aa + ' cannot be set to ' +agentVal.value.bool, 
				Lasr_langPackage.Literals.AGENT_VALUE__VALUE,
				TYPEMISMATCH_AGENT_PARENT)
		}
		if(agentVal.aa == "displayName" && (agentVal.value.bool == 'true' || agentVal.value.bool == 'false')) {
			error('Type mismatch: '+ agentVal.aa + ' cannot be set to ' +agentVal.value.bool, 
				Lasr_langPackage.Literals.AGENT_VALUE__VALUE,
				TYPEMISMATCH_AGENT_DISPLAYNAME)
		}
		if(agentVal.aa == "defaultLanguageCode" && (agentVal.value.bool == 'true' || agentVal.value.bool == 'false')) {
			error('Type mismatch: '+ agentVal.aa + ' cannot be set to ' +agentVal.value.bool, 
				Lasr_langPackage.Literals.AGENT_VALUE__VALUE,
				TYPEMISMATCH_AGENT_DEFAULTLANGUAGECODE)
		}
		if(agentVal.aa == "timezone" && (agentVal.value.bool == 'true' || agentVal.value.bool == 'false')) {
			error('Type mismatch: '+ agentVal.aa + ' cannot be set to ' +agentVal.value.bool, 
				Lasr_langPackage.Literals.AGENT_VALUE__VALUE,
				TYPEMISMATCH_AGENT_TIMEZONE)
		}
		if(agentVal.aa == "enableLogging" && (agentVal.value.v.name !== 'true' || agentVal.value.v.name !== 'false')) {
			error('Type mismatch:  '+ agentVal.aa + ' cannot be set to ' +agentVal.value.v.name.class.typeName, 
				Lasr_langPackage.Literals.AGENT_VALUE__VALUE,
				TYPEMISMATCH_AGENT_ENABLELOGGING)
		}
	}
	
	def checkAgentParams(Agent agent) {
		val agentValues = newArrayList
		for(AgentValue v : agent.values) {
			agentValues.add(v.aa)
		}
		
		if (!agentValues.contains('parent')) {
		error('You must define the parent variable', 
				Lasr_langPackage.Literals.AGENT__VALUES,
				MISSING_AGENT_PARENT)
		} else if (!agentValues.contains('displayName')) {
			error('You must define the displayName variable', 
					Lasr_langPackage.Literals.AGENT__VALUES,
					MISSING_AGENT_DISPLAYNAME)
		} else if (!agentValues.contains('defaultLanguageCode')) {
			error('You must define the defaultLanguageCode variable', 
					Lasr_langPackage.Literals.AGENT__VALUES,
					MISSING_AGENT_DEFAULTLANGUAGECODE)
		} else if (!agentValues.contains('timezone')) {
			error('You must define the timezone variable', 
					Lasr_langPackage.Literals.AGENT__VALUES,
					MISSING_AGENT_TIMEZONE)
		} else if (!agentValues.contains('enableLogging')) {
			error('You must define the enableLogging variable', 
					Lasr_langPackage.Literals.AGENT__VALUES,
					MISSING_AGENT_ENABLELOGGING)
		}
	}
	
	def checkIntentParams(Intent i) {
		val intentValues = newArrayList
		for(IntentValue v : i.values) {
			if(v instanceof IntentRequired) {
				intentValues.add(v.req.v)	
			}
		}		
		if (!intentValues.contains('displayName')) {
			error('You must define the displayName variable', 
					Lasr_langPackage.Literals.INTENT__VALUES,
					MISSING_INTENT_DISPLAYNAME)
		} 
	}
}