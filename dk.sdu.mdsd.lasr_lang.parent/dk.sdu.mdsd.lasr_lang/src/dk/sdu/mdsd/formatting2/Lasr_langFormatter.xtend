/*
 * generated by Xtext 2.16.0
 */
package dk.sdu.mdsd.formatting2

import com.google.inject.Inject
import dk.sdu.mdsd.lasr_lang.Agent
import dk.sdu.mdsd.lasr_lang.Model
import dk.sdu.mdsd.services.Lasr_langGrammarAccess
import org.eclipse.xtext.formatting2.AbstractFormatter2
import org.eclipse.xtext.formatting2.IFormattableDocument
import dk.sdu.mdsd.lasr_lang.Lasr_langPackage.Literals.*
import dk.sdu.mdsd.lasr_lang.Parameter

class Lasr_langFormatter extends AbstractFormatter2 {
	
	@Inject extension Lasr_langGrammarAccess

	def dispatch void format(Model model, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		for (virtualIntent : model.virtualIntents) {
			virtualIntent.format
		}
		for (intent : model.intents) {
			intent.format
		}
		for (entityType : model.entitytypes) {
			entityType.format
		}
	}

	def dispatch void format(Agent agent, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		for (agentValue : agent.values) {
			agentValue.format
		}
	}
	
	def dispatch void format(Parameter parameter, extension IFormattableDocument document) {
		// TODO: format HiddenRegions around keywords, attributes, cross references, etc. 
		
	}
	
	// TODO: implement for AgentValue, Value, Intent, IntentValue, TrainingPhrases, Phrase, Sentence, Parameters, Parameter, Prompt, Messages, VirtualIntent, EntityType, Entities, Entity
}