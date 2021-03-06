/*
 * generated by Xtext 2.16.0
 */
package dk.sdu.mdsd.ide

import com.google.inject.Guice
import dk.sdu.mdsd.Lasr_langRuntimeModule
import dk.sdu.mdsd.Lasr_langStandaloneSetup
import org.eclipse.xtext.util.Modules2

/**
 * Initialization support for running Xtext languages as language servers.
 */
class Lasr_langIdeSetup extends Lasr_langStandaloneSetup {

	override createInjector() {
		Guice.createInjector(Modules2.mixin(new Lasr_langRuntimeModule, new Lasr_langIdeModule))
	}
	
}
