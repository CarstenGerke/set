/**
 * Copyright (c) 2017 DB Netz AG and others.
 * 
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v2.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v20.html
 */
package org.eclipse.set.feature.export.pdf

import com.google.common.collect.Maps
import org.eclipse.set.basis.FreeFieldInfo
import org.eclipse.set.model.tablemodel.CellContent
import org.eclipse.set.model.tablemodel.CompareCellContent
import org.eclipse.set.model.tablemodel.Footnote
import org.eclipse.set.model.tablemodel.Table
import org.eclipse.set.model.tablemodel.TableContent
import org.eclipse.set.model.tablemodel.TableRow
import org.eclipse.set.model.titlebox.Titlebox
import org.eclipse.set.utils.ToolboxConfiguration
import java.util.List
import java.util.Map
import javax.xml.parsers.DocumentBuilderFactory
import javax.xml.parsers.ParserConfigurationException
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.w3c.dom.Attr
import org.w3c.dom.Document
import org.w3c.dom.Element

import static extension org.eclipse.set.model.tablemodel.extensions.CellContentExtensions.*
import static extension org.eclipse.set.model.tablemodel.extensions.TableContentExtensions.*
import static extension org.eclipse.set.model.tablemodel.extensions.TableExtensions.*
import static extension org.eclipse.set.model.tablemodel.extensions.TableRowExtensions.*
import static extension org.eclipse.set.utils.StringExtensions.*
import org.eclipse.set.utils.table.TableSpanUtils
import javax.xml.XMLConstants

/**
 * Transformation from {@link Table} to TableDocument {@link Document}.
 * 
 * @author Schaefer
 */
class TableToTableDocument {

	static final Logger logger = LoggerFactory.getLogger(
		typeof(TableToTableDocument));

	val Document doc
	var String tablename
	var int groupNumber
	val Map<Integer, Footnote> footnotes = Maps.newHashMap
	var TableSpanUtils spanUtils

	private new() throws ParserConfigurationException {
		val docFactory = DocumentBuilderFactory.newInstance
		// Disallow external entity access
		docFactory.setAttribute(XMLConstants.ACCESS_EXTERNAL_DTD, ""); // $NON-NLS-1$
		docFactory.setAttribute(XMLConstants.ACCESS_EXTERNAL_STYLESHEET, ""); // $NON-NLS-1$
		val docBuilder = docFactory.newDocumentBuilder
		doc = docBuilder.newDocument
	}

	/**
	 * Creates a new Transformation.
	 */
	static def TableToTableDocument createTransformation() throws ParserConfigurationException {
		return new TableToTableDocument
	}

	/**
	 * @param table the table model
	 * @param titlebox the titlebox model
	 * 
	 * @return the table document
	 */
	def Document transformToDocument(Table table, Titlebox titlebox,
		FreeFieldInfo freeFieldInfo) {
		tablename = table?.rootDescriptor?.label
		logger.debug('''tablename=«tablename»''')
		doc.appendChild(table.transform(titlebox, freeFieldInfo))
		return doc
	}

	/**
	 * @param titlebox the titlebox model
	 * 
	 * @return the titlebox document
	 */
	def Document transformToDocument(Titlebox titlebox) {
		tablename = "titlebox export"
		doc.appendChild(titlebox.transform)
		return doc
	}

	private def Element create doc.createElement("Table") transform(Table table,
		Titlebox titlebox, FreeFieldInfo freeFieldInfo) {
		appendChild(table.tablecontent.transform)
		appendChild(footnotes.transformToFootnotes)
		appendChild(titlebox.transform)
		appendChild(freeFieldInfo.transform)
		return
	}

	private def Element create doc.createElement("Rows") transform(
		TableContent content) {
		val rowsElement = it
		val rows = content.table.tableRows
		spanUtils = new TableSpanUtils(rows)
		rows.forEach[rowsElement.appendChild(transform(rows))]
		if (ToolboxConfiguration.pdfExportTestFilling &&
			content.rowgroups.empty) {
			rowsElement.appendChild(createTestRowElement("1", content))
			rowsElement.appendChild(createTestRowElement("2", content))
			rowsElement.appendChild(createTestRowElement("3", content))
		}
		return
	}

	private def Element createTestRowElement(Element rowsElement,
		String groupNumber, TableContent content) {
		val rowElement = doc.createElement("Row")
		val numberAttr = doc.createAttribute("group-number")
		numberAttr.value = groupNumber
		rowElement.attributeNode = numberAttr
		content.table.columns.indexed.forEach [
			rowElement.appendChild(createTestCell(key + 1))
		]
		return rowElement
	}

	private def Element create doc.createElement("Row") transform(TableRow row,
		List<TableRow> rows) {

		// row number
		attributeNode = row.transformToGroupNumber(rows)

		// cells
		val rowElement = it
		val rowIndex = rows.indexOf(row)
		val cells = row.content

		logger.
			debug('''groupNumber=«groupNumber» («FOR c : cells SEPARATOR " "»«c.plainStringValue»«ENDFOR»)''')

		cells.indexed.forEach [
			logger.debug('''column=«key»''')
			val isRemarkColumn = value.isRemarkColumn(cells)

			// Check for required span merges
			var rowSpan = 1
			if (spanUtils.isMergeAllowed(key, rowIndex)) {
				val spanUp = spanUtils.getRowSpanUp(key, rowIndex);
				val spanDown = spanUtils.getRowSpanDown(key, rowIndex);

				// If spanUp > 0, we have already merged this span
				// in a previous iteration. Otherwise adjust the rowSpan
				if (spanUp == 0 && spanDown > 0) {
					rowSpan = spanDown + 1;
				} else if (spanUp > 0) {
					rowSpan = 0
				}
			}

			if (rowSpan > 0) {
				rowElement.appendChild(
					value.createCell(key + 1, rowSpan, isRemarkColumn))
			}
		]

		// remember footnotes for later
		row.footnotes.forEach[footnotes.put(number, it)]

		return
	}

	private def Element createTestCell(int columnNumber) {
		val cellElement = doc.createElement("Cell")
		cellElement.attributeNode = createColumnAttribute(columnNumber)
		cellElement.appendChild(createTestContent(columnNumber))
		return cellElement
	}

	private def dispatch Element createCell(CellContent content,
		int columnNumber, int rowSpan, boolean isRemarkColumn) {
		val cellElement = doc.createElement("Cell")

		cellElement.attributeNode = createColumnAttribute(columnNumber)
		cellElement.attributeNode = createRowSpanAttribute(rowSpan)
		cellElement.appendChild(
			content.createContent(columnNumber, isRemarkColumn))

		return cellElement
	}

	private def dispatch Element createCell(Void content, int columnNumber,
		int rowSpan, boolean isRemarkColumn) {
		val cellElement = doc.createElement("Cell")

		cellElement.attributeNode = createColumnAttribute(columnNumber)
		cellElement.attributeNode = createRowSpanAttribute(rowSpan)
		cellElement.appendChild(
			null.createContent(columnNumber, isRemarkColumn))

		return cellElement
	}

	private def Element create doc.createElement("Footnote") transform(
		Footnote footnote) {
		attributeNode = footnote.createFootnoteAttribute
		textContent = footnote.text
		return
	}

	private def Attr createFootnoteAttribute(Footnote footnote) {
		val footnoteAttr = doc.createAttribute("footnote-number")
		footnoteAttr.value = Integer.toString(footnote.number)
		return footnoteAttr
	}

	private def boolean isRemarkColumn(CellContent content,
		List<CellContent> rowContent) {
		return rowContent.last === content
	}

	private def Attr create doc.createAttribute("group-number") transformToGroupNumber(
		TableRow row, List<TableRow> rows) {
		groupNumber = rows.indexOf(row) + 1
		value = groupNumber.toString
		logger.debug('''group-number=«value»''')
		return
	}

	private def String checkForTestOutput(String text, int columnNumber) {
		if (ToolboxConfiguration.isPdfExportTestFilling && text.nullOrEmpty) {
			return Integer.toString(columnNumber)
		}
		return text
	}

	private def Element createTestContent(int columnNumber) {
		val element = doc.createElement("StringContent")
		element.textContent = Integer.toString(columnNumber)
		return element
	}

	private def dispatch Element createContent(CellContent content,
		int columnNumber, boolean isRemarkColumn) {
		val element = doc.createElement("StringContent")
		val stringValue = content.plainStringValue
		element.textContent = if (isRemarkColumn)
			stringValue.checkForTestOutput(columnNumber)
		else
			stringValue.checkForTestOutput(columnNumber).
				intersperseWithZeroSpacesSC
		return element
	}

	private def dispatch Element createContent(Void content, int columnNumber,
		boolean isRemarkColumn) {
		val element = doc.createElement("StringContent")
		element.textContent = "".checkForTestOutput(columnNumber)
		logger.
			warn('''no content at groupNumber=«groupNumber» column=«columnNumber»''')
		return element
	}

	private def dispatch Element createContent(CompareCellContent content,
		int columnNumber, boolean isRemarkColumn) {
		val element = doc.createElement("DiffContent")
		element.appendChild(
			content.oldValue.checkForTestOutput(columnNumber).
				createDiffComponent("OldValue", isRemarkColumn))
		element.appendChild(
			content.newValue.checkForTestOutput(columnNumber).
				createDiffComponent("NewValue", isRemarkColumn))
		return element
	}

	private def Attr createColumnAttribute(int columnNumber) {
		val columnAttr = doc.createAttribute("column-number")
		columnAttr.value = Integer.toString(columnNumber)
		return columnAttr
	}

	private def Attr createRowSpanAttribute(int rowSpan) {
		val attr = doc.createAttribute("number-rows-spanned")
		attr.value = Integer.toString(rowSpan)
		return attr
	}

	private def Element createDiffComponent(String content, String elementName,
		boolean isRemarkColumn) {
		val element = doc.createElement(elementName)
		element.textContent = if (isRemarkColumn)
			content
		else
			content.intersperseWithZeroSpacesSC
		return element
	}

	private def Element create doc.createElement("TitleBox") transform(
		Titlebox titlebox) {
		val titleboxElement = it
		titlebox.field.indexed.forEach [
			titleboxElement.appendChild(transform(it.key, it.value))
		]
		return
	}

	private def Element create doc.createElement("Field") transform(int index,
		String value) {
		attributeNode = index.transformToAddressAttr
		textContent = value?.intersperseWithZeroSpacesSC
		return
	}

	private def Attr create doc.createAttribute("address") transformToAddressAttr(
		int index) {
		val address = index + 1
		value = address.toString
		return
	}

	private def Element create doc.createElement("Freefield") transform(
		FreeFieldInfo freeFieldInfo) {
		val significantInformation = freeFieldInfo.significantInformation
		if (significantInformation !== null) {
			appendChild(
				significantInformation.transformToSignificantInformation)
		}
		return
	}

	private def Element create doc.createElement("SignificantInformation") transformToSignificantInformation(
		String significantInformation) {
		textContent = significantInformation
		return
	}

	private def Element create doc.createElement("Footnotes")
	transformToFootnotes(Map<Integer, Footnote> footnotes) {
		val element = it
		footnotes.keySet.sort.forEach [
			element.appendChild(footnotes.get(it).transform)
		]
		return
	}
}
