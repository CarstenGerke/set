/**
 * Copyright (c) 2018 DB Netz AG and others.
 * 
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v2.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v20.html
 */
package org.eclipse.set.feature.validation.report

import java.util.Comparator
import java.util.List
import org.eclipse.emf.common.util.Enumerator
import org.eclipse.emf.ecore.xmi.XMIException
import org.eclipse.set.basis.IModelSession
import org.eclipse.set.basis.constants.ValidationResult.Outcome
import org.eclipse.set.basis.exceptions.CustomValidationProblem
import org.eclipse.set.core.services.enumtranslation.EnumTranslationService
import org.eclipse.set.core.services.version.PlanProVersionService
import org.eclipse.set.feature.validation.Messages
import org.eclipse.set.feature.validation.utils.XMLNodeFinder
import org.eclipse.set.model.validationreport.ObjectScope
import org.eclipse.set.model.validationreport.ValidationProblem
import org.eclipse.set.model.validationreport.ValidationReport
import org.eclipse.set.model.validationreport.ValidationSeverity
import org.eclipse.set.model.validationreport.ValidationreportFactory
import org.eclipse.set.utils.ToolboxConfiguration
import org.xml.sax.SAXParseException

import static extension org.eclipse.set.basis.extensions.IModelSessionExtensions.*
import static extension org.eclipse.set.feature.validation.utils.ObjectMetadataXMLReader.*

/**
 * Transforms a {@link IModelSession} into a {@link ValidationReport}.
 * 
 * @author Schaefer
 */
class SessionToValidationReportTransformation {

	val Messages messages

	val PlanProVersionService versionService
	var ValidationReport report
	val XMLNodeFinder xmlNodeFinder = new XMLNodeFinder();
	val EnumTranslationService enumService
	val severityOrder = newLinkedList(ValidationSeverity.ERROR,
		ValidationSeverity.WARNING, ValidationSeverity.SUCCESS)

	new(Messages messages, PlanProVersionService versionService,
		EnumTranslationService enumService) {
		this.messages = messages
		this.versionService = versionService
		this.enumService = enumService
	}

	/**
	 * @param session the model session
	 * 
	 * @return the validation report
	 */
	def ValidationReport transform(IModelSession session) {
		xmlNodeFinder.read(session?.toolboxFile);

		report = session.transformCreate
		val filePath = session?.toolboxFile?.path
		report.fileName = filePath?.toString ?: ""
		report.modelLoaded = if (session.hasLoadedModel) {
			messages.YesMsg
		} else {
			messages.NoMsg
		}
		report.valid = session?.validationResult?.outcome?.transform
		report.xsdValid = session?.validationResult?.xsdOutcome?.transform
		report.emfValid = session?.validationResult?.emfOutcome?.transform

		report.supportedVersion = versionService.createSupportedVersion
		report.usedVersion = versionService.createUsedVersion(
			session.toolboxFile.modelPath)
		report.toolboxVersion = ToolboxConfiguration.toolboxVersion.longVersion

		report.problems.clear
		val problems = <ValidationProblem>newLinkedList

		// transform the IO problems
		problems.addAll(
			session.validationResult.xsdErrors.transform(messages.XsdProblemMsg,
				ValidationSeverity.ERROR, messages.XsdErrorSuccessMsg))

		// transform the XSD problems
		problems.addAll(
			session.validationResult.xsdWarnings.transform(
				messages.XsdWarningMsg, ValidationSeverity.WARNING,
				messages.XsdSuccessMsg))
		problems.addAll(
			session.validationResult.ioErrors.transform(messages.IoProblemMsg,
				ValidationSeverity.ERROR, messages.IoSuccessMsg))

		// transform custom problems
		session.validationResult.customProblems.forEach [
			problems.add(
				transform
			)
		]
		problems.sortProblem
		report.problems.addAll(problems)
		// Add subwork information
		val subworkTypes = session.subworkTypes
		val subworkCount = subworkTypes.length
		report.subworkCount = subworkCount.toString
		if (subworkCount > 0)
			report.subworkTypes = String.join(", ", subworkTypes)
		else
			report.subworkTypes = messages.NoSubworks

		return report
	}

	private def <T extends Exception> List<ValidationProblem> transform(
		List<T> errors, String type, ValidationSeverity severity,
		String successMessage) {
		val result = <ValidationProblem>newLinkedList
		if (errors.empty) {
			result.add(
				type.transform(successMessage)
			)
		} else {
			errors.forEach [
				result.add(
					transform(type, severity)
				)
			]
		}
		return result
	}

	private def ValidationReport create ValidationreportFactory.eINSTANCE.createValidationReport
	transformCreate(IModelSession session) {
	}

	private def String transform(Outcome outcome) {
		switch (outcome) {
			case VALID: {
				return messages.ValidMsg
			}
			case INVALID: {
				return messages.InvalidMsg
			}
			default: {
				return messages.ValidationNotSupportedMsg
			}
		}
	}

	private def ValidationProblem transform(
		Exception exception,
		String type,
		ValidationSeverity severity
	) {
		val cause = exception.cause

		if (cause instanceof XMIException) {
			return cause.transformException(type, severity)
		}
		if (cause instanceof SAXParseException) {
			return cause.transformException(type, severity)
		}
		return exception.transformException(type, severity)
	}

	private def dispatch ValidationProblem create ValidationreportFactory.eINSTANCE.createValidationProblem
	transformException(
		XMIException exception,
		String type,
		ValidationSeverity severity
	) {
		it.type = type
		it.severity = severity
		it.severityText = severity.translate
		lineNumber = exception.line
		message = exception.transformToMessage
		val xmlNode = xmlNodeFinder.findNodeByLineNumber(lineNumber)
		if (xmlNode !== null) {
			objectArt = xmlNode.objectType
			objectScope = xmlNode.objectScope
			objectState = xmlNode.objectState
		}
		return
	}

	private def dispatch ValidationProblem create ValidationreportFactory.eINSTANCE.createValidationProblem
	transformException(
		SAXParseException exception,
		String type,
		ValidationSeverity severity
	) {
		it.type = type
		it.severity = severity
		it.severityText = severity.translate
		lineNumber = exception.lineNumber
		message = exception.transformToMessage
		val xmlNode = xmlNodeFinder.findNodeByLineNumber(lineNumber)
		if (xmlNode !== null) {
			objectArt = xmlNode.objectType
			objectScope = xmlNode.objectScope
			objectState = xmlNode.objectState
		}
		return
	}

	private def dispatch ValidationProblem create ValidationreportFactory.eINSTANCE.createValidationProblem
	transformException(
		Exception exception,
		String type,
		ValidationSeverity severity
	) {
		it.type = type
		it.severity = severity
		it.severityText = severity.translate
		lineNumber = 0
		message = exception.transformToMessage
		objectArt = ""
		objectScope = ObjectScope.UNKNOWN
		attributeName = ""
		return
	}

	private def ValidationProblem create ValidationreportFactory.eINSTANCE.createValidationProblem
	transform(
		CustomValidationProblem problem
	) {
		type = problem.type
		severity = problem.severity
		severityText = problem.severity.translate
		lineNumber = problem.lineNumber
		message = problem.message
		objectArt = problem.objectArt
		objectScope = problem.objectScope
		objectState = problem.objectState
		attributeName = problem.attributeName
		return
	}

	private def ValidationProblem create ValidationreportFactory.eINSTANCE.createValidationProblem
	transform(
		String errorType,
		String message
	) {
		type = errorType
		severity = ValidationSeverity.SUCCESS
		severityText = severity.translate
		it.message = message
	}

	private def Iterable<String> getSubworkTypes(IModelSession session) {
		val fachdaten = session.planProSchnittstelle?.LSTPlanung?.fachdaten?.
			ausgabeFachdaten
		if (fachdaten === null)
			return #[]
		val subtypes = newHashMap
		fachdaten.map[untergewerkArt?.wert?.toString].forEach [
			if (!subtypes.containsKey(it)) {
				subtypes.put(it, 1)
			} else {
				val count = subtypes.get(it)
				subtypes.put(it, count + 1)
			}
		]
		val result = newLinkedList
		subtypes.forEach[type, count|result.add('''«type» («count»)''')]
		return result
	}

	/**
	 * Sort problems by severity and line number, then set
	 * id
	 * @param problems the list of problems
	 */
	private def void sortProblem(List<ValidationProblem> problems) {
		problems.sort(new Comparator<ValidationProblem>() {
			override compare(ValidationProblem o1, ValidationProblem o2) {
				val compareSeverity = severityOrder.indexOf(o1.severity).
					compareTo(severityOrder.indexOf(o2.severity))
				if (compareSeverity === 0) {
					return o1.lineNumber.compareTo(o2.lineNumber)
				}
				return compareSeverity
			}

		})
		problems.forEach[it, index|id = index + 1]
	}

	private def dispatch String transformToMessage(Exception exception) {
		return exception.message
	}

	private def dispatch String transformToMessage(
		SAXParseException exception) {
		val original = exception.message
		return original.replaceFirst("cvc[^:]+: ", "")
	}

	private def String translate(Enumerator enumerator) {
		if (enumerator === null) {
			return null
		}
		return enumService.translate(enumerator).alternative
	}

}
