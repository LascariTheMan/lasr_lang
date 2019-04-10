/*
 * generated by Xtext 2.16.0
 */
package dk.sdu.mdsd.validation

import dk.sdu.mdsd.lasr_lang.Agent
import dk.sdu.mdsd.lasr_lang.AgentValue
import dk.sdu.mdsd.lasr_lang.Intent
import dk.sdu.mdsd.lasr_lang.IntentValue
import dk.sdu.mdsd.lasr_lang.Lasr_langPackage
import dk.sdu.mdsd.lasr_lang.Parameter
import dk.sdu.mdsd.lasr_lang.Prompt
import dk.sdu.mdsd.lasr_lang.Sentence
import dk.sdu.mdsd.lasr_lang.Words
import org.eclipse.xtext.validation.Check

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
	public static val DUPLICATE_ENTRY = 'duplicateEntryError'
	public val lit = Lasr_langPackage.eINSTANCE
	// MIssing validation:
	// Agent and Intent: validate that only 1 of each parameter has been written.
	
	@Check
	def checkIfAgentParamsAreMissing(Agent agent) {
		checkAgentParams(agent)
	}
	
	@Check
	def checkIfAgentParamsAreUpper(AgentValue av) {
		if (!Character.isUpperCase(av.value.v.name.charAt(0))) {
        warning('Agent attributes should start with a capital', av.value.v, 
                lit.getValueName_Name,
                INVALID_NAME)
    }
	}
	
	@Check
	def checkIfAgentParamsAreAllowed(AgentValue agentVal) {
		checkAgentParams(agentVal)
	}
	
	@Check
	def ifRequiredParameterThenPrompts(Parameter param){
		if(param.req == "required" && param.prompts.isEmpty()) {
			error("You must create at least one prompt if the parameter is "+ param.req.toString(),
				null,
				IF_REQUIRED_PARAM_THEN_PROMPT)
		}
	}
	
	@Check
	def promptStringShouldNotBeEmpty(Prompt p) {
		for(Words w : p.words) {			
			if("".equals(w.name)) {
				warning("A prompt should not be empty",
					lit.getPrompt_Words,
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
					lit.getSentence_Words,
					PHRASE_STRING_SHOULD_NOT_BE_EMPTY
				)
			}
		}
	}
	
	@Check
	def checkIntentHasOnlyOneOfEachParam(Intent intent) {
		val intentValSet = newHashSet
			for (IntentValue v : intent.values) {
				if(!intentValSet.add(v.iv.v)){
					error("Duplicate entry", v.iv, null, DUPLICATE_ENTRY)
				}
			}
		}		
	
	@Check
	def checkAgentHasOnlyOneOfEachParam(Agent a) {
		val agentValSet = newHashSet
		for(var i = 0 ; i < a.values.length ; i++) {
			if(!agentValSet.add(a.values.get(i).aa)){
				error("Duplicate entry", a.values.get(i), null, DUPLICATE_ENTRY)
			}
		}		
	}
	
	def checkAgentParams(AgentValue agentVal) {
		val bool = agentVal.value.bool
		if(agentVal.value.bool == 'true' || agentVal.value.bool == 'false') {
			if(agentVal.aa == "parent") {
				error('Type mismatch: '+ agentVal.aa + ' cannot be set to ' + bool, 
					lit.getAgentValue_Value,
					TYPEMISMATCH_AGENT_PARENT)
			}
			if(agentVal.aa == "displayName") {
				error('Type mismatch: '+ agentVal.aa + ' cannot be set to ' + bool, 
					lit.getAgentValue_Value,
					TYPEMISMATCH_AGENT_DISPLAYNAME)
			}
			if(agentVal.aa == "defaultLanguageCode") {
				error('Type mismatch: '+ agentVal.aa + ' cannot be set to ' + bool, 
					lit.getAgentValue_Value,
					TYPEMISMATCH_AGENT_DEFAULTLANGUAGECODE)
			}
			if(agentVal.aa == "timezone") {
				error('Type mismatch: '+ agentVal.aa + ' cannot be set to ' + bool, 
					lit.getAgentValue_Value,
					TYPEMISMATCH_AGENT_TIMEZONE)
			}
			if(agentVal.aa == "enableLogging" && (agentVal.value.v.name !== 'true' || agentVal.value.v.name !== 'false')) {
				error('Type mismatch:  '+ agentVal.aa + ' cannot be set to ' +agentVal.value.v.name.class.typeName, 
					lit.getAgentValue_Value,
					TYPEMISMATCH_AGENT_ENABLELOGGING)
			}	
		}
		
	}
	
	def checkAgentParams(Agent agent) {
		val agentValues = newArrayList
		for(AgentValue v : agent.values) {
			agentValues.add(v.aa)
		}
		
		if (!agentValues.contains('parent')) {
			error('You must define the parent variable', 
					null,
					MISSING_AGENT_PARENT)
		} else if (!agentValues.contains('displayName')) {
			error('You must define the displayName variable', 
					null,
					MISSING_AGENT_DISPLAYNAME)
		} else if (!agentValues.contains('defaultLanguageCode')) {
			error('You must define the defaultLanguageCode variable', 
					null,
					MISSING_AGENT_DEFAULTLANGUAGECODE)
		} else if (!agentValues.contains('timezone')) {
			error('You must define the timezone variable', 
					null,
					MISSING_AGENT_TIMEZONE)
		} else if (!agentValues.contains('enableLogging')) {
			error('You must define the enableLogging variable', 
					null,
					MISSING_AGENT_ENABLELOGGING)
		}
	}
}