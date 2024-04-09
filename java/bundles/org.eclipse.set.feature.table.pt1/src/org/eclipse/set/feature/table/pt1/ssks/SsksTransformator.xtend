/**
 * Copyright (c) 2016 DB Netz AG and others.
 * 
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v2.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v20.html
 */
package org.eclipse.set.feature.table.pt1.ssks;

import java.math.BigDecimal
import java.util.Collections
import java.util.HashSet
import java.util.LinkedList
import java.util.List
import java.util.Map
import java.util.Set
import org.apache.commons.lang3.ThreadUtils
import org.eclipse.set.basis.MixedStringComparator
import org.eclipse.set.basis.constants.ToolboxConstants
import org.eclipse.set.basis.graph.TopPoint
import org.eclipse.set.core.services.Services
import org.eclipse.set.core.services.enumtranslation.EnumTranslationService
import org.eclipse.set.core.services.graph.BankService
import org.eclipse.set.core.services.graph.TopologicalGraphService
import org.eclipse.set.feature.table.pt1.AbstractPlanPro2TableModelTransformator
import org.eclipse.set.model.planpro.Ansteuerung_Element.Unterbringung
import org.eclipse.set.model.planpro.Basisobjekte.Punkt_Objekt
import org.eclipse.set.model.planpro.Basisobjekte.Punkt_Objekt_TOP_Kante_AttributeGroup
import org.eclipse.set.model.planpro.Geodaten.TOP_Kante
import org.eclipse.set.model.planpro.Geodaten.Technischer_Punkt
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Hl10
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Hl11
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Hl12a
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Hl12b
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Hl2
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Hl3a
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Hl3b
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Hl4
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Hl5
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Hl6a
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Hl6b
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Hl7
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Hl8
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Hl9a
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Hl9b
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Hp0
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Hp02Lp
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Hp1
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Hp2
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Kl
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Ks1
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Ks2
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.MsGeD
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.MsRt
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.MsWs2swP
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.MsWsGeWs
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.MsWsRtWs
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.MsWsSwWs
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Ne14
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Ne2
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.OzBk
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Sh1
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Vr0
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Vr1
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Vr2
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.ZlO
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.ZlU
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Zp10
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Zp10Ls
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Zp9
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Zp9Ls
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Zs1
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Zs12
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Zs13
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Zs1A
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Zs2
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Zs2v
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Zs3
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Zs3v
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Zs6
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Zs7
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Zs8
import org.eclipse.set.model.planpro.Signalbegriffe_Ril_301.Zs8A
import org.eclipse.set.model.planpro.Signalbegriffe_Struktur.Signalbegriff_ID_TypeClass
import org.eclipse.set.model.planpro.Signale.ENUMAutoEinstellung
import org.eclipse.set.model.planpro.Signale.ENUMGeltungsbereich
import org.eclipse.set.model.planpro.Signale.Signal
import org.eclipse.set.model.planpro.Signale.Signal_Befestigung
import org.eclipse.set.model.planpro.Signale.Signal_Rahmen
import org.eclipse.set.model.planpro.Signale.Signal_Signalbegriff
import org.eclipse.set.model.tablemodel.ColumnDescriptor
import org.eclipse.set.model.tablemodel.TableRow
import org.eclipse.set.model.tablemodel.extensions.CellContentExtensions
import org.eclipse.set.ppmodel.extensions.container.MultiContainer_AttributeGroup
import org.eclipse.set.ppmodel.extensions.utils.Case
import org.eclipse.set.ppmodel.extensions.utils.GeoPosition
import org.eclipse.set.utils.events.TableDataChangeEvent
import org.eclipse.set.utils.table.Pt1TableChangeProperties
import org.eclipse.set.utils.table.TMFactory
import org.locationtech.jts.geom.Coordinate
import org.locationtech.jts.geom.GeometryFactory
import org.locationtech.jts.geom.LineString
import org.osgi.service.event.EventAdmin
import org.slf4j.Logger
import org.slf4j.LoggerFactory

import static org.eclipse.set.feature.table.pt1.ssks.SsksColumns.*
import static org.eclipse.set.model.planpro.Ansteuerung_Element.ENUMAussenelementansteuerungArt.*
import static org.eclipse.set.model.planpro.BasisTypen.ENUMWirkrichtung.*
import static org.eclipse.set.model.planpro.Signale.ENUMAnschaltdauer.*
import static org.eclipse.set.model.planpro.Signale.ENUMBefestigungArt.*
import static org.eclipse.set.model.planpro.Signale.ENUMBeleuchtet.*
import static org.eclipse.set.model.planpro.Signale.ENUMFiktivesSignalFunktion.*
import static org.eclipse.set.model.planpro.Signale.ENUMGeltungsbereich.*
import static org.eclipse.set.model.planpro.Signale.ENUMRahmenArt.*
import static org.eclipse.set.model.planpro.Signale.ENUMSignalArt.*
import static org.eclipse.set.model.planpro.Signale.ENUMSignalFunktion.*
import static org.eclipse.set.model.planpro.Signale.ENUMTunnelsignal.*

import static extension org.eclipse.set.ppmodel.extensions.BasisAttributExtensions.*
import static extension org.eclipse.set.ppmodel.extensions.GeoKanteExtensions.*
import static extension org.eclipse.set.ppmodel.extensions.GeoPunktExtensions.*
import static extension org.eclipse.set.ppmodel.extensions.MultiContainer_AttributeGroupExtensions.*
import static extension org.eclipse.set.ppmodel.extensions.PunktObjektExtensions.*
import static extension org.eclipse.set.ppmodel.extensions.PunktObjektStreckeExtensions.*
import static extension org.eclipse.set.ppmodel.extensions.PunktObjektTopKanteExtensions.*
import static extension org.eclipse.set.ppmodel.extensions.SignalExtensions.*
import static extension org.eclipse.set.ppmodel.extensions.SignalRahmenExtensions.*
import static extension org.eclipse.set.ppmodel.extensions.SignalbegriffExtensions.*
import static extension org.eclipse.set.ppmodel.extensions.StellelementExtensions.*
import static extension org.eclipse.set.ppmodel.extensions.TopKanteExtensions.*
import static extension org.eclipse.set.ppmodel.extensions.UnterbringungExtensions.*
import static extension org.eclipse.set.ppmodel.extensions.UrObjectExtensions.*
import static extension org.eclipse.set.ppmodel.extensions.utils.CacheUtils.*
import static extension org.eclipse.set.ppmodel.extensions.utils.CollectionExtensions.*
import static extension org.eclipse.set.utils.math.BigDecimalExtensions.*
import static extension org.eclipse.set.utils.math.DoubleExtensions.*

/**
 * Table transformation for a Signaltabelle (Ssks).
 * 
 * @author Dittmer
 */
class SsksTransformator extends AbstractPlanPro2TableModelTransformator {

	static val Logger LOGGER = LoggerFactory.getLogger(
		typeof(SsksTransformator))
	static val SIGNALBEGRIFF_COMPARATOR = new MixedStringComparator(
		"(?<letters1>[A-Za-z]*)(?<number>[0-9]*)(?<letters2>[A-Za-z]*)")

	val TopologicalGraphService topGraphService
	val BankService bankingService
	val EventAdmin eventAdmin
	val String tableShortCut

	new(Set<ColumnDescriptor> cols,
		EnumTranslationService enumTranslationService,
		TopologicalGraphService topGraphService, BankService bankingService,
		EventAdmin eventAdmin, String tableShortCut) {
		super(cols, enumTranslationService)
		this.topGraphService = topGraphService
		this.bankingService = bankingService
		this.eventAdmin = eventAdmin
		this.tableShortCut = tableShortCut
	}

	override transformTableContent(MultiContainer_AttributeGroup container,
		TMFactory factory) {
		// iterate signal-wise
		for (Signal signal : container.signal.filter[isPlanningObject].filter [
			ssksSignal
		]) {
			if (Thread.currentThread.interrupted) {
				return null
			}
			try {
				val rowGroup = factory.newRowGroup(signal)

				// iterate over Befestigungen
				val befestigungsgruppen = signal.befestigungsgruppen
				for (var int i = 0; i < 2; i++) {
					val isHauptbefestigung = (i == 0)
					val gruppe = befestigungsgruppen.get(i)
					val signalRahmen = signal.signalRahmenForBefestigung(gruppe)

					val TableRow row = rowGroup.newTableRow

					// Certain columns have the same values in the rows for the "Haupt-" and "Nebenbefestigung". 
					// In order to avoid the redundant display, we only display these values in the line of the "Hauptbefestigung"
					if (isHauptbefestigung || !gruppe.empty) {

						fillConditional(
							row,
							cols.getColumn(Bezeichnung_Signal),
							signal,
							[isHauptbefestigung],
							[bezeichnung.bezeichnungTabelle.wert],
							[""]
						)

						fillConditional(
							row,
							cols.getColumn(Reales_Signal),
							signal,
							[isHauptbefestigung],
							[
								signal?.signalReal?.signalRealAktivSchirm?.
									signalArt?.wert?.translate
							]
						)

						fillConditional(
							row,
							cols.getColumn(Funktion_Ohne_Signal),
							signal,
							[isHauptbefestigung],
							[
								signal?.signalReal?.funktionOhneSignal?.wert?.
									translate
							]
						)

						fillIterable(
							row,
							cols.getColumn(Fiktives_Signal),
							signal,
							[
								signal?.signalFiktiv?.fiktivesSignalFunktion?.
									map [
										wert?.translate
									] ?: Collections.emptyList
							],
							null
						)

						fillConditional(
							row,
							cols.getColumn(Strecke),
							signal,
							[isHauptbefestigung],
							[
								punktObjektStrecke.unique.strecke.bezeichnung.
									bezeichnungStrecke.wert
							]
						)

						fill(
							row,
							cols.getColumn(Km),
							signal,
							[punktObjektStrecke.unique.streckeKm.wert]
						)

						if (signal.isSsksSignalNichtAndere) {
							fill(
								row,
								cols.getColumn(Sonstige_Zulaessige_Anordnung),
								signal,
								[
									signal?.signalReal?.signalRealAktiv?.
										sonstigeZulaessigeAnordnung?.wert?.
										translate
								]
							)

							fillIterable(
								row,
								cols.getColumn(Lichtraumprofil),
								signal,
								[
									val s = it
									val mountpoints = gruppe.map [
										s.getMountPoint(it)
									]
									val topEdges = mountpoints.map[topKante].
										toSet
									topEdges.map [
										gleisLichtraum?.lichtraumprofil?.wert?.
											translate
									]
								],
								null
							)

							if (bankingService.isFindBankingComplete) {
								fillIterable(
									row,
									cols.getColumn(Ueberhoehung),
									signal,
									[
										bankingService.findBankValue(
											new TopPoint(signal)).map [
											multiply(new BigDecimal(1000)).
												toTableInteger ?: ""
										]
									],
									null
								)
							} else {
								// Fill Banking through thread, when find process not complete
								row.fillUeberhoehung(signal)
							}

							// Abstand Mastmitte
							if (!Services.cacheService.existCache(
								ToolboxConstants.CacheId.GEOKANTE_GEOMETRY) ||
								ThreadUtils.allThreads.filterNull.exists [
									name.
										startsWith('''«tableShortCut»/«ToolboxConstants.CacheId.GEOKANTE_GEOMETRY»''') &&
										isAlive
								]) {

								row.fillSideDistanceSync(signal)
							} else {
								val abstandMastmitteLinks = new HashSet<Pair<Long, Long>>
								val abstandMastmitteRechts = new HashSet<Pair<Long, Long>>

								signal.initAbstandMastmitte(signal.signalRahmen,
									abstandMastmitteLinks,
									abstandMastmitteRechts);

								fillIterable(
									row,
									cols.getColumn(Mastmitte_Links),
									signal,
									[
										abstandMastmitteLinks.map [
											'''«key» «IF value > 0»(«value»)«ENDIF»'''
										]
									],
									null,
									[toString]
								)

								fillIterable(
									row,
									cols.getColumn(Mastmitte_Rechts),
									signal,
									[
										abstandMastmitteRechts.map [
											'''«key» «IF value > 0»(«value»)«ENDIF»'''
										]
									],
									null,
									[toString]
								)
							}
							// Sichtbarkeit Soll
							fillConditional(
								row,
								cols.getColumn(Sichtbarkeit_Soll),
								signal,
								[isHauptbefestigung],
								[
									signalReal?.signalsichtSoll?.wert?.toString
								]
							)

							fillConditional(
								row,
								cols.getColumn(Sichtbarkeit_Mindest),
								signal,
								[isHauptbefestigung],
								[
									signalReal?.signalsichtMindest?.wert?.
										toString
								]
							)

							fillConditional(
								row,
								cols.getColumn(Sichtbarkeit_Ist),
								signal,
								[isHauptbefestigung],
								[
									signalReal?.signalsichtErreichbar?.wert?.
										toString
								]
							)

							fillConditional(
								row,
								cols.getColumn(Entfernung),
								signal,
								[isHauptbefestigung],
								[
									signalReal?.signalRealAktivSchirm?.
										richtpunktentfernung?.wert?.toString
								]
							)

							fillConditional(
								row,
								cols.getColumn(Richtpunkt),
								signal,
								[isHauptbefestigung],
								[
									signalReal?.signalRealAktivSchirm?.
										richtpunkt?.wert
								]
							)

							fillIterable(
								row,
								cols.getColumn(Befestigung),
								signalRahmen,
								[map[signalBefestigung.fillBefestigung].toSet],
								null,
								[toString]
							)

							fillIterable(
								row,
								cols.getColumn(Anordnung_Regelzeichnung),
								signalRahmen,
								[fillRegelzeichnung.toSet],
								null,
								[toString]
							)

							fillIterable(
								row,
								cols.getColumn(Obere_Lichtpunkthoehe),
								signalRahmen,
								[
									filter[
										rahmenArt.wert == ENUM_RAHMEN_ART_SCHIRM
									].map [
										signalBefestigung?.
											signalBefestigungAllg?.
											obereLichtpunkthoehe?.wert
									].toSet.map [ b |
										if (b !== null)
											(Math.round(b.doubleValue * 1000)).
												toString
										else
											""
									]
								],
								null,
								[it]
							)

							fillConditional(
								row,
								cols.getColumn(Streuscheibe_Art),
								signal,
								[isHauptbefestigung],
								[
									signalReal?.signalRealAktivSchirm?.
										streuscheibeArt?.wert?.translate
								]
							)

							fillConditional(
								row,
								cols.getColumn(Streuscheibe_Stellung),
								signal,
								[isHauptbefestigung],
								[
									signalReal?.signalRealAktivSchirm?.
										streuscheibeBetriebsstellung?.wert?.
										translate
								]
							)

							fillIterable(
								row,
								cols.getColumn(Fundament_Art_Regelzeichnung),
								signalRahmen,
								[
									val regelzeichnung = map[fundament].
										filterNull.flatMap[IDRegelzeichnung].map [
											value?.fillRegelzeichnung
										].filterNull
									val fundament = map[
										fundament?.signalBefestigungAllg?.
											fundamentArt?.wert
									].filterNull.map[translate].filterNull
									return (regelzeichnung + fundament).toSet
								],
								null,
								[toString]
							)

							fillIterable(
								row,
								cols.getColumn(Fundament_Hoehe),
								signalRahmen,
								[
									map[
										fundament?.signalBefestigungAllg?.
											hoeheFundamentoberkante?.wert
									].filterNull.toSet
								],
								null,
								[toTableInteger(1000)]
							)

							fillConditional(
								row,
								cols.getColumn(Schaltkasten_Bezeichnung),
								signal,
								[
									stellelement?.energie?.AEAAllg?.
										aussenelementansteuerungArt?.wert ==
										ENUM_AUSSENELEMENTANSTEUERUNG_ART_OBJEKTCONTROLLER
								],
								[
									stellelement?.energie?.bezeichnung?.
										bezeichnungAEA?.wert
								]
							)

							fillConditional(
								row,
								cols.getColumn(Schaltkasten_Entfernung),
								signal,
								[controlBox !== null],
								[
									distance(controlBox).toTableDecimal
								]
							)

							fillConditional(
								row,
								cols.getColumn(
									Schaltkasten_Separat_Bezeichnung),
								signal,
								[hasSchaltkastenSeparatBezeichnung],
								[
									stellelement?.information?.bezeichnung?.
										bezeichnungAEA?.wert
								]
							)

							fillConditional(
								row,
								cols.getColumn(Dauerhaft_Nacht),
								signal,
								[isHauptbefestigung],
								[
									(signalReal?.signalRealAktiv?.tunnelsignal?.
										wert ==
										ENUM_TUNNELSIGNAL_MIT_DAUERNACHTSCHALTUNG).
										translate
								]
							)

							fillIterable(
								row,
								cols.getColumn(Schirm_Hp_Hl),
								signalRahmen,
								[fillSignalisierungHpHl],
								MIXED_STRING_COMPARATOR,
								[it]
							)

							fillIterable(
								row,
								cols.getColumn(Schirm_Ks_Vr),
								signalRahmen,
								[fillSignalisierungKsVr],
								MIXED_STRING_COMPARATOR,
								[it]
							)

							fillIterable(
								row,
								cols.getColumn(Schirm_Zl_Kl),
								signalRahmen,
								[fillSignalisierungZlKl],
								MIXED_STRING_COMPARATOR,
								[it]
							)

							fillSwitch(
								row,
								cols.getColumn(Schirm_Ra_Sh),
								signal,
								new Case<Signal>(
									[
										hasSignalbegriffID(Sh1) &&
											signalReal?.geltungsbereich?.wert ==
												ENUMGeltungsbereich.
													ENUM_GELTUNGSBEREICH_DV
									],
									["Ra 12"]
								),
								new Case<Signal>(
									[
										hasSignalbegriffID(Sh1) &&
											signalReal?.geltungsbereich?.wert ==
												ENUMGeltungsbereich.
													ENUM_GELTUNGSBEREICH_DS
									],
									["Sh 1"]
								),
								new Case<Signal>([hasSignalbegriffID(Sh1)], ["x"])
							)

							fillIterable(
								row,
								cols.getColumn(Schirm_Zs),
								signalRahmen,
								[fillSignalisierungSchirmZs],
								MIXED_STRING_COMPARATOR,
								[it]
							)

							fillIterable(
								row,
								cols.getColumn(Zusatzanzeiger_Zs_2),
								signalRahmen,
								[fillSignalisierungSymbol(typeof(Zs2))],
								MIXED_STRING_COMPARATOR,
								[it]
							)

							fillIterable(
								row,
								cols.getColumn(Zusatzanzeiger_Zs_2v),
								signalRahmen,
								[fillSignalisierungSymbol(typeof(Zs2v))],
								MIXED_STRING_COMPARATOR,
								[it]
							)

							fillIterable(
								row,
								cols.getColumn(Zusatzanzeiger_Zs_3),
								signalRahmen,
								[fillSignalisierungSymbolGeschaltet(typeof(Zs3))],
								MIXED_STRING_COMPARATOR,
								[it]
							)

							fillIterable(
								row,
								cols.getColumn(Zusatzanzeiger_Zs_3v),
								signalRahmen,
								[
									fillSignalisierungSymbolGeschaltet(
										typeof(Zs3v))
								],
								MIXED_STRING_COMPARATOR,
								[it]
							)

							fillIterable(
								row,
								cols.getColumn(Zusatzanzeiger_Zs),
								signalRahmen,
								[fillSignalisierungZusatzanzeigerZs],
								MIXED_STRING_COMPARATOR,
								[it]
							)

							fillIterable(
								row,
								cols.getColumn(Zusatzanzeiger_Zp),
								signalRahmen,
								[fillSignalisierungZp],
								MIXED_STRING_COMPARATOR,
								[it]
							)

							fillIterable(
								row,
								cols.getColumn(Zusatzanzeiger_Kombination),
								signalRahmen,
								[fillSignalisierungKombination],
								null,
								[it],
								", "
							)

							fillIterable(
								row,
								cols.getColumn(Nachgeordnetes_Signal),
								signalRahmen,
								[
									filter[r|r.IDSignalNachordnung !== null].map [ r |
										r.signalNachordnung.bezeichnung.
											bezeichnungTabelle.wert
									] + container.signalRahmen.filter [ r |
										r?.IDSignalNachordnung?.value?.
											identitaet?.wert ==
											signal.identitaet.wert
									].map [ r |
										r.signal.bezeichnung.bezeichnungTabelle.
											wert
									]
								],
								MIXED_STRING_COMPARATOR,
								[it]
							)

							fillIterable(
								row,
								cols.getColumn(Mastschild),
								signalRahmen,
								[fillSignalisierungMastschild],
								MIXED_STRING_COMPARATOR,
								[it]
							)

							fillIterable(
								row,
								cols.getColumn(Weitere_Regelzeichnung_Nr),
								signalRahmen,
								[fillSignalisierungWeitere],
								MIXED_STRING_COMPARATOR,
								[it]
							)

							fill(
								row,
								cols.getColumn(Automatische_Fahrtstellung),
								signal,
								[fillSonstigesAutomatischeFahrtstellung]
							)

							fill(
								row,
								cols.getColumn(Dunkelschaltung),
								signal,
								[fillSonstigesDunkelschaltung]
							)

							fill(
								row,
								cols.getColumn(Durchfahrt_Erlaubt),
								signal,
								[fillSonstigesDurchfahrtErlaubt]
							)

							fillConditional(
								row,
								cols.getColumn(Besetzte_Ausfahrt),
								signal,
								[signalFstr?.besetzteAusfahrt?.wert !== null],
								[signalFstr.besetzteAusfahrt.wert.translate]
							)

							fill(
								row,
								cols.getColumn(Loeschung_Zs_1__Zs_7),
								signalRahmen,
								[fillSonstigesLoeschungZs1Zs7]
							)

							fillIterable(
								row,
								cols.getColumn(Ueberwachung_Zs_2),
								signal,
								[
									val zs2 = getSignalbegriffe(Zs2).filterNull
									// Is there any Zs2 without zs2Ueberwacht = true?
									if (zs2.empty || zs2.findFirst [
										signalSignalbegriffAllg?.
											zs2Ueberwacht === null ||
											signalSignalbegriffAllg.
												zs2Ueberwacht.wert == false
									] !== null)
										return #[""]

									return zs2.map [
										signalbegriffID?.symbol ?: "?"
									]
								],
								null
							)

							fillIterable(
								row,
								cols.getColumn(Ueberwachung_Zs_2v),
								signal,
								[
									val zs2v = getSignalbegriffe(Zs2v).
										filterNull
									// Is there any Zs2v without zs2Ueberwacht = true?
									if (zs2v.empty || zs2v.findFirst [
										signalSignalbegriffAllg?.
											zs2Ueberwacht === null ||
											signalSignalbegriffAllg.
												zs2Ueberwacht.wert == false
									] !== null)
										return #[""]

									return zs2v.map [
										signalbegriffID?.symbol ?: "?"
									]
								],
								null
							)
						} else {
							for (var int j = 5; j < 48; j++) {
								fillBlank(row, j)
							}
						}

						fill(
							row,
							cols.getColumn(Bemerkung),
							signal,
							[fillBemerkung(signalRahmen, row)]
						)
					} else {
						for (var int k = 0; k < 48; k++) {
							fillBlank(row, k)
						}
					}
				}
			} catch (Exception e) {
				LOGGER.error('''«e.

class .simpleName»: «e.message» - failed to transform table contents''', e)
				val TableRow row = factory.newTableRow(signal);
				fill(
					row,
					cols.getColumn(Reales_Signal),
					signal,
					[throw new RuntimeException(e)]
				)
			}

		}

		return factory.table
	}

	static Map<TableRow, Signal> waitingFillSideDistanceSignal = newHashMap

	private def void fillSideDistanceSync(TableRow row, Signal signal) {

		#[Mastmitte_Links, Mastmitte_Rechts].forEach [
			fill(
				row,
				cols.getColumn(it),
				signal,
				[CellContentExtensions.HOURGLASS_ICON]
			)
		]
		waitingFillSideDistanceSignal.put(row, signal)
		val threadName = '''«tableShortCut»/«ToolboxConstants.CacheId.GEOKANTE_GEOMETRY»'''
		if (!Thread.allStackTraces.keySet.exists[name.startsWith(threadName)]) {
			new Thread([
				signal.container.GEOKante.forEach[geometry]
				val changeProperties = newArrayList
				waitingFillSideDistanceSignal.forEach [ r, s |
					val abstandMastmitteLinks = new HashSet<Pair<Long, Long>>
					val abstandMastmitteRechts = new HashSet<Pair<Long, Long>>
					val containerType = s.container.containerType
					s.initAbstandMastmitte(s.signalRahmen,
						abstandMastmitteLinks, abstandMastmitteRechts);
					val leftDistance = new Pt1TableChangeProperties(
						containerType, r, cols.getColumn(Mastmitte_Links),
						abstandMastmitteLinks.map [
							'''«key» «IF value > 0»(«value»)«ENDIF»'''
						].toList, ITERABLE_FILLING_SEPARATOR)
					changeProperties.add(leftDistance)
					val rightDistance = new Pt1TableChangeProperties(
						containerType, r, cols.getColumn(Mastmitte_Rechts),
						abstandMastmitteRechts.map [
							'''«key» «IF value > 0»(«value»)«ENDIF»'''
						].toList, ITERABLE_FILLING_SEPARATOR)
					changeProperties.add(rightDistance)
				]
				val updateValuesEvent = new TableDataChangeEvent(
					tableShortCut.toLowerCase, changeProperties)
				TableDataChangeEvent.sendEvent(eventAdmin, updateValuesEvent)
			], threadName).start
		}
	}

	private def void initAbstandMastmitte(
		Signal signal,
		List<Signal_Rahmen> signalRahmen,
		Set<Pair<Long, Long>> abstandMastmitteLinks,
		Set<Pair<Long, Long>> abstandMastmitteRechts
	) {
		signalRahmen.map [
			signalBefestigungIterator.findFirst [
				signalBefestigungAllg.befestigungArt.wert ==
					ENUM_BEFESTIGUNG_ART_REGELANORDNUNG_MAST_HOCH ||
					signalBefestigungAllg.befestigungArt.wert ==
						ENUM_BEFESTIGUNG_ART_REGELANORDNUNG_MAST_NIEDRIG
			]
		].filterNull.map[singlePoints].flatten.toSet.forEach [ p |
			val seitlicherAbstand = Math.round(
				p.seitlicherAbstand.wert.doubleValue * 1000)
			val wirkrichtung = signal.getWirkrichtung(p.topKante)

			val distanceFromPoint = 7000 - Math.abs(seitlicherAbstand)
			val perpendicularRotation = wirkrichtung == ENUM_WIRKRICHTUNG_IN &&
					seitlicherAbstand > 0 ? 90 : -90
			var opposideSideDistance = 0.0
			try {
				opposideSideDistance = p.opposideSideDistance(
					p.coordinate.effectiveRotation + perpendicularRotation,
					distanceFromPoint / 1000)
			} catch (Exception e) {
				LOGGER.error(e.message)
			}
			if ((wirkrichtung == ENUM_WIRKRICHTUNG_IN &&
				seitlicherAbstand > 0) ||
				(wirkrichtung == ENUM_WIRKRICHTUNG_GEGEN &&
					seitlicherAbstand < 0)) {
				abstandMastmitteLinks.add(Math.abs(seitlicherAbstand) ->
					Math.round(opposideSideDistance * 1000))
			}
			if ((wirkrichtung == ENUM_WIRKRICHTUNG_IN &&
				seitlicherAbstand < 0) ||
				(wirkrichtung == ENUM_WIRKRICHTUNG_GEGEN &&
					seitlicherAbstand > 0)) {
				abstandMastmitteRechts.add(Math.abs(seitlicherAbstand) ->
					Math.round(opposideSideDistance * 1000))
			}
		]
	}

	private def Double opposideSideDistance(
		Punkt_Objekt_TOP_Kante_AttributeGroup potk, double angle,
		double distance) {
		val position = potk.coordinate
		val rad = angle * Math.PI / 180
		val transformX = Math.sin(rad) * distance + position.coordinate.x
		val transformY = Math.cos(rad) * distance + position.coordinate.y
		val geometryFactory = new GeometryFactory()
		val perpendicularLine = geometryFactory.createLineString(
			#[position.coordinate, new Coordinate(transformX, transformY)])
		val relevantGeoKante = potk.container.GEOKante.filter [
			geoArt instanceof TOP_Kante && geoArt !== potk.IDTOPKante
		].map[geometry].filterNull.toList
		return relevantGeoKante.getDistanceOpposide(perpendicularLine, position)
	}

	private def Double getDistanceOpposide(
		Iterable<LineString> relevantGeoKante, LineString line,
		GeoPosition position) {
		val intersectionPoint = relevantGeoKante.filter[intersects(line)].map [
			intersection(line)
		]
		val trackDistance = intersectionPoint.map [
			coordinate.distance(position.coordinate)
		].toList
		if (trackDistance.isNullOrEmpty) {
			return 0.0
		}
		return trackDistance.min
	}

// IMPROVE use explicit structure
	private static def List<List<Signal_Befestigung>> getBefestigungsgruppen(
		Signal signal) {
		val result = new LinkedList<List<Signal_Befestigung>>

		val rahmen = signal.signalRahmen
		val befestigungen = rahmen.map[signalBefestigung].filter [
			signalBefestigungAllg.befestigungArt.wert ==
				ENUM_BEFESTIGUNG_ART_REGELANORDNUNG_MAST_HOCH ||
				signalBefestigungAllg.befestigungArt.wert ==
					ENUM_BEFESTIGUNG_ART_REGELANORDNUNG_MAST_NIEDRIG

		].toSet

		// condition "zwei Befestigungen"
		if (befestigungen.size == 2) {
			val hauptbefestigungen = rahmen.filter [
				rahmenArt.wert == ENUM_RAHMEN_ART_SCHIRM
			].map [
				signalBefestigung
			].filter [
				signalBefestigungAllg.befestigungArt.wert ==
					signalBefestigungAllg.befestigungArt.wert ==
					ENUM_BEFESTIGUNG_ART_REGELANORDNUNG_MAST_HOCH ||
					signalBefestigungAllg.befestigungArt.wert ==
						ENUM_BEFESTIGUNG_ART_REGELANORDNUNG_MAST_NIEDRIG
			].toList
			val nebenbefestigungen = befestigungen.filter [
				!hauptbefestigungen.contains(it)
			].toList

			result.add(hauptbefestigungen)
			result.add(nebenbefestigungen)
		} else if (befestigungen.size > 2) {
			throw new IllegalArgumentException('''«signal.bezeichnung?.bezeichnungAussenanlage?.toString» has more than two Befestigung Signal''')
		} else {
			result.add(rahmen.map[signalBefestigung])
			result.add(new LinkedList<Signal_Befestigung>())
		}

		return result
	}

	private def String fillBefestigung(Signal_Befestigung befestigung) {
		val art = befestigung.signalBefestigungAllg.befestigungArt.wert

		switch (art) {
			case ENUM_BEFESTIGUNG_ART_SONSTIGE:
				return befestigung.fillBearbeitungsvermerke
			default:
				return befestigung.signalBefestigungAllg.befestigungArt.wert.
					translate
		}
	}

	private def String fillBearbeitungsvermerke(
		Signal_Befestigung befestigung) {
		val bearbeitungsvermerke = befestigung?.signalBefestigungAllg?.
			befestigungArt?.IDBearbeitungsvermerk

		if (bearbeitungsvermerke.empty) {
			throw new IllegalArgumentException(
				'''Befestigung Art of Befestigung «befestigung.identitaet.wert» has no Bearbeitungsvermerke.'''
			)
		}

		return '''«FOR b : bearbeitungsvermerke SEPARATOR ", "»«
			b.value.bearbeitungsvermerkAllg.kurztext.wert»«ENDFOR»'''
	}

	private static def boolean isSsksSignal(Signal signal) {
		if (signal?.signalFiktiv !== null) {
			return true
		}

		val signalReal = signal?.signalReal
		val signalRealAktiv = signalReal?.signalRealAktiv
		val signalRealAktivSchirm = signalReal?.signalRealAktivSchirm
		val signalArt = signalRealAktivSchirm?.signalArt?.wert
		val signalFunktion = signalReal?.signalFunktion?.wert

		return (signalArt !== null && signalArt != ENUM_SIGNAL_ART_ANDERE) ||
			(signalFunktion !== null &&
				signalFunktion ==
					ENUM_SIGNAL_FUNKTION_ALLEINSTEHENDES_ZUSATZSIGNAL) ||
			(signalReal !== null && signalRealAktiv === null &&
				signalRealAktivSchirm === null &&
				(signal.hasSignalbegriffID(Ne14) ||
					signal.hasSignalbegriffID(OzBk)))
	}

	private static def boolean isSsksSignalNichtAndere(Signal signal) {
		val signalArt = signal?.signalReal?.signalRealAktivSchirm?.signalArt?.
			wert
		val signalFunktion = signal?.signalReal?.signalFunktion?.wert
		return ( signalArt !== null && signalArt != ENUM_SIGNAL_ART_ANDERE ) ||
			( signalFunktion !== null &&
				signalFunktion ==
					ENUM_SIGNAL_FUNKTION_ALLEINSTEHENDES_ZUSATZSIGNAL)
	}

	private static def List<String> fillRegelzeichnung(
		List<Signal_Rahmen> signalRahmen) {
		return signalRahmen.map [
			signalBefestigung.IDRegelzeichnung.map [ z |
				z?.value.fillRegelzeichnung
			]
		].flatten.toList
	}

	private static def boolean hasSchaltkastenSeparatBezeichnung(
		Signal signal) {
		val stellelement = signal.stellelement
		return stellelement?.information?.AEAAllg?.aussenelementansteuerungArt?.
			wert == ENUM_AUSSENELEMENTANSTEUERUNG_ART_OBJEKTCONTROLLER &&
			stellelement?.IDInformation?.value?.identitaet?.wert !=
				stellelement?.IDEnergie?.value?.identitaet?.wert
	}

	private static def List<String> fillSignalisierungHpHl(
		List<Signal_Rahmen> signalRahmen) {
		return signalRahmen.map[signalbegriffe].flatten.map [
			signalbegriffID.fillSignalisierungHpHl
		].filterNull.toList
	}

	private static def List<String> fillSignalisierungKsVr(
		List<Signal_Rahmen> signalRahmen) {
		return signalRahmen.map[signalbegriffe].flatten.map [
			signalbegriffID.fillSignalisierungKsVr
		].filterNull.toList
	}

	private static def List<String> fillSignalisierungZlKl(
		List<Signal_Rahmen> signalRahmen) {
		return signalRahmen.map[signalbegriffe].flatten.map [
			signalbegriffID.fillSignalisierungZlKl
		].filterNull.toList
	}

	private static def List<String> fillSignalisierungSchirmZs(
		List<Signal_Rahmen> signalRahmen) {
		return signalRahmen.map[signalbegriffe].flatten.map [
			signalbegriffID.fillSignalisierungSchirmZs
		].filterNull.toList
	}

	private static def List<String> fillSignalisierungZp(
		List<Signal_Rahmen> signalRahmen) {
		return signalRahmen.map[signalbegriffe].flatten.map [
			signalbegriffID.fillSignalisierungZp
		].filterNull.toList
	}

	private static def Iterable<String> fillSignalisierungKombination(
		List<Signal_Rahmen> signalRahmen
	) {
		val kombinationen = signalRahmen.filter [
			rahmenArt.wert == ENUM_RAHMEN_ART_ZUSATZANZEIGER
		].map[signalbegriffe.toSet].map[map[signalbegriffID.typeName].toSet].
			filter [
				size > 1
			]
		return kombinationen.map[fillSignalisierungKombination]
	}

	private static def String fillSignalisierungKombination(
		Set<String> kombination) {
		val sorted = kombination.toList.sortWith(SIGNALBEGRIFF_COMPARATOR)
		return '''«FOR name : sorted SEPARATOR " + "»«name.splitSignalbegriff»«ENDFOR»'''
	}

	private static def String splitSignalbegriff(String text) {
		return text.replaceFirst("([^0-9]+)([0-9]+)", "$1 $2")
	}

	private static def List<String> fillSignalisierungZusatzanzeigerZs(
		List<Signal_Rahmen> signalRahmen) {
		return signalRahmen.map[signalbegriffe].flatten.map [
			fillSignalisierungZusatzanzeigerZs
		].filterNull.toList
	}

	private static def List<String> fillSignalisierungMastschild(
		List<Signal_Rahmen> signalRahmen
	) {
		return signalRahmen.map[signalbegriffe].flatten.map[signalbegriffID].
			toList.fillSignalisierungMastschildForBegriffe
	}

	private static def <T> List<String> fillSignalisierungSymbol(
		List<Signal_Rahmen> signalRahmen,
		Class<T> type
	) {
		return signalRahmen.map[signalbegriffe].flatten.map [
			signalbegriffID.fillSignalisierungSymbol(type)
		].filterNull.toList
	}

	private static def <T> List<String> fillSignalisierungSymbolGeschaltet(
		List<Signal_Rahmen> signalRahmen,
		Class<T> type
	) {
		return signalRahmen.map[signalbegriffe].flatten.map [
			fillSignalisierungSymbolGeschaltet(type)
		].filterNull.toList
	}

	private static def String fillSignalisierungHpHl(
		Signalbegriff_ID_TypeClass begriff
	) {
		switch (begriff) {
			case begriff instanceof Hp0 || begriff instanceof Hp02Lp:
				return "0"
			case begriff instanceof Hp1 || begriff instanceof Hl11:
				return "1"
			case begriff instanceof Hp2 || begriff instanceof Hl2:
				return "2"
			case begriff instanceof Hl3a:
				return "3a"
			case begriff instanceof Hl3b:
				return "3b"
			case begriff instanceof Hl4:
				return "4"
			case begriff instanceof Hl5:
				return "5"
			case begriff instanceof Hl6a:
				return "6a"
			case begriff instanceof Hl6b:
				return "6b"
			case begriff instanceof Hl7:
				return "7"
			case begriff instanceof Hl8:
				return "8"
			case begriff instanceof Hl9a:
				return "9a"
			case begriff instanceof Hl9b:
				return "9b"
			case begriff instanceof Hl10:
				return "10"
			case begriff instanceof Hl11:
				return "11"
			case begriff instanceof Hl12a:
				return "12a"
			case begriff instanceof Hl12b:
				return "12b"
			default:
				return null
		}
	}

	private static def String fillSignalisierungKsVr(
		Signalbegriff_ID_TypeClass begriff
	) {
		switch (begriff) {
			case begriff instanceof Vr0:
				return "0"
			case begriff instanceof Ks1 || begriff instanceof Vr1:
				return "1"
			case begriff instanceof Ks2 || begriff instanceof Vr2:
				return "2"
			default:
				return null
		}
	}

	private static def String fillSignalisierungZlKl(
		Signalbegriff_ID_TypeClass begriff
	) {
		switch (begriff) {
			case begriff instanceof ZlO || begriff instanceof ZlU:
				return "Zl"
			case begriff instanceof Kl:
				return "Kl"
			default:
				return null
		}
	}

	private static def String fillSignalisierungSchirmZs(
		Signalbegriff_ID_TypeClass begriff
	) {
		switch (begriff) {
			case begriff instanceof Zs1 || begriff instanceof Zs1A:
				return "1"
			case begriff instanceof Zs7:
				return "7"
			default:
				return null
		}
	}

	private static def String fillSignalisierungZp(
		Signalbegriff_ID_TypeClass begriff
	) {
		switch (begriff) {
			case begriff instanceof Zp9 || begriff instanceof Zp9Ls:
				return "9"
			case begriff instanceof Zp10 || begriff instanceof Zp10Ls:
				return "10"
			default:
				return null
		}
	}

	private static def <T> String fillSignalisierungSymbol(
		Signalbegriff_ID_TypeClass begriff,
		Class<T> type
	) {
		switch (begriff) {
			case type.isInstance(begriff):
				return begriff.symbol
			default:
				return null
		}
	}

	private static def <T> String fillSignalisierungSymbolGeschaltet(
		Signal_Signalbegriff signalbegriff,
		Class<T> type
	) {
		val id = signalbegriff.signalbegriffID
		val geschaltet = signalbegriff?.signalSignalbegriffAllg?.geschaltet?.
			wert
		switch (id) {
			case type.isInstance(id) && !geschaltet:
				return '''«id.symbol»F'''
			case type.isInstance(id) && geschaltet:
				return '''«id.symbol»'''
			default:
				return null
		}
	}

	private static def <T> String fillSignalisierungZusatzanzeigerZs(
		Signal_Signalbegriff signalbegriff
	) {
		val id = signalbegriff.signalbegriffID
		val geschaltet = signalbegriff?.signalSignalbegriffAllg?.geschaltet?.
			wert
		switch (id) {
			case id instanceof Zs6 && geschaltet:
				return "6"
			case id instanceof Zs6 && !geschaltet:
				return "6F"
			case id instanceof Zs8 || id instanceof Zs8A:
				return "8"
			case id instanceof Zs12:
				return "12"
			case id instanceof Zs13 && geschaltet:
				return "13"
			case id instanceof Zs13 && !geschaltet:
				return "13F"
			default:
				return null
		}
	}

	private static def List<String> fillSignalisierungMastschildForBegriffe(
		List<Signalbegriff_ID_TypeClass> begriffe
	) {
		val result = new LinkedList<String>

		if (begriffe.containsInstanceOf(typeof(MsWsRtWs)) &&
			!begriffe.containsInstanceOf(typeof(MsGeD))) {
			result.add("ws/rt/ws")
		}

		if (begriffe.containsInstanceOf(typeof(MsWsRtWs)) &&
			begriffe.containsInstanceOf(typeof(MsGeD))) {
			result.add("ws/rt/ws +V")
		}

		if (begriffe.containsInstanceOf(typeof(MsRt))) {
			result.add("rt")
		}

		if (begriffe.containsInstanceOf(typeof(MsWsGeWs))) {
			result.add("ws/ge/ws/ge/ws")
		}

		if (begriffe.containsInstanceOf(typeof(MsWsSwWs))) {
			result.add("ws/sw/ws/sw/ws")
		}

		if (begriffe.containsInstanceOf(typeof(MsWs2swP))) {
			result.add("Sp")
		}

		return result
	}

	private static def <T> boolean containsInstanceOf(
		List<Signalbegriff_ID_TypeClass> begriffe,
		Class<T> type
	) {
		return begriffe.fold(false, [result, id|result || type.isInstance(id)])
	}

	private static def List<String> fillSignalisierungWeitere(
		List<Signal_Rahmen> signalRahmen) {
		val rahmen = signalRahmen.filter [
			!signalbegriffe.filter [
				signalbegriffID instanceof Ne2 ||
					signalbegriffID instanceof Ne14
			].empty
		].toList
		return rahmen.map[IDRegelzeichnung?.value].filterNull.map [
			fillRegelzeichnung
		].toList
	}

	private static def String fillSonstigesAutomatischeFahrtstellung(
		Signal signal) {
		val signalArt = signal.signalReal?.signalRealAktivSchirm?.signalArt?.
			wert
		val zlSignal = signal.signalReal?.signalRealAktiv?.autoEinstellung?.wert
		val signalFiktivFunktion = signal.signalFiktiv?.fiktivesSignalFunktion?.
			map [
				wert
			]?.filterNull
		val signalFiktivAutoEinstellung = signal.signalFiktiv?.autoEinstellung?.
			wert

		switch (signalArt) {
			case signalArt != ENUM_SIGNAL_ART_HAUPTSIGNAL &&
				signalArt != ENUM_SIGNAL_ART_HAUPTSPERRSIGNAL &&
				signalArt != ENUM_SIGNAL_ART_MEHRABSCHNITTSSIGNAL &&
				signalArt != ENUM_SIGNAL_ART_MEHRABSCHNITTSSPERRSIGNAL &&
				signalArt != ENUM_SIGNAL_ART_HAUPTSPERRSIGNAL_NE_14_LS &&
				signalArt != ENUM_SIGNAL_ART_SPERRSIGNAL &&
				(signalFiktivFunktion === null ||
					!signalFiktivFunktion.contains(
						ENUM_FIKTIVES_SIGNAL_FUNKTION_ZUG_START_ZIEL_BK) &&
						!signalFiktivFunktion.contains(
							ENUM_FIKTIVES_SIGNAL_FUNKTION_ZUG_START_ZIEL_NE_14)):
				return ""
			case zlSignal == ENUMAutoEinstellung.ENUM_AUTO_EINSTELLUNG_ZL && (
				signalArt == ENUM_SIGNAL_ART_HAUPTSIGNAL ||
				signalArt == ENUM_SIGNAL_ART_HAUPTSPERRSIGNAL ||
				signalArt == ENUM_SIGNAL_ART_MEHRABSCHNITTSSIGNAL ||
				signalArt == ENUM_SIGNAL_ART_MEHRABSCHNITTSSPERRSIGNAL ||
				signalArt == ENUM_SIGNAL_ART_HAUPTSPERRSIGNAL_NE_14_LS ||
				signalArt == ENUM_SIGNAL_ART_SPERRSIGNAL):
				return "ZL"
			case signalFiktivAutoEinstellung ==
				ENUMAutoEinstellung.ENUM_AUTO_EINSTELLUNG_ZL &&
				signalFiktivFunktion !== null && (
				signalFiktivFunktion.contains(
					ENUM_FIKTIVES_SIGNAL_FUNKTION_ZUG_START_ZIEL_BK) ||
					signalFiktivFunktion.contains(
						ENUM_FIKTIVES_SIGNAL_FUNKTION_ZUG_START_ZIEL_NE_14)):
				return "ZL"
			case zlSignal == ENUMAutoEinstellung.ENUM_AUTO_EINSTELLUNG_SB && (
				signalArt == ENUM_SIGNAL_ART_HAUPTSIGNAL ||
				signalArt == ENUM_SIGNAL_ART_HAUPTSPERRSIGNAL ||
				signalArt == ENUM_SIGNAL_ART_MEHRABSCHNITTSSIGNAL ||
				signalArt == ENUM_SIGNAL_ART_MEHRABSCHNITTSSPERRSIGNAL ||
				signalArt == ENUM_SIGNAL_ART_HAUPTSPERRSIGNAL_NE_14_LS ||
				signalArt == ENUM_SIGNAL_ART_SPERRSIGNAL):
				return "SB"
			case signalFiktivAutoEinstellung ==
				ENUMAutoEinstellung.ENUM_AUTO_EINSTELLUNG_SB &&
				signalFiktivFunktion !== null && (
				signalFiktivFunktion.contains(
					ENUM_FIKTIVES_SIGNAL_FUNKTION_ZUG_START_ZIEL_BK) ||
					signalFiktivFunktion.contains(
						ENUM_FIKTIVES_SIGNAL_FUNKTION_ZUG_START_ZIEL_NE_14)):
				return "SB"
			default:
				return "o"
		}
	}

	private def String fillSonstigesDunkelschaltung(Signal signal) {
		val dunkelschaltung = signal?.signalReal?.dunkelschaltung?.wert

		switch (dunkelschaltung) {
			case dunkelschaltung !== null && dunkelschaltung:
				return translate(true)
			case dunkelschaltung !== null && !dunkelschaltung:
				return translate(false)
			default:
				return null
		}
	}

	private static def String fillSonstigesDurchfahrtErlaubt(Signal signal) {
		val durchfahrt = signal.signalFstr?.durchfahrt?.wert
		val geltungsbereich = signal.signalReal?.geltungsbereich?.wert

		switch (durchfahrt) {
			case ENUM_DURCHFAHRT_VERBOTEN:
				return ""
			case ENUM_DURCHFAHRT_ERLAUBT:
				return "x"
			case durchfahrt == ENUM_DURCHFAHRT_NUR_MIT_SH1 &&
				geltungsbereich == ENUM_GELTUNGSBEREICH_DV:
				return "Ra 12"
			case durchfahrt == ENUM_DURCHFAHRT_NUR_MIT_SH1 &&
				geltungsbereich == ENUM_GELTUNGSBEREICH_DS:
				return "Sh 1"
			default:
				return null
		}
	}

	private static def String fillSonstigesLoeschungZs1Zs7(
		List<Signal_Rahmen> signalRahmen) {
		val anschaltdauer = signalRahmen.map[signalbegriffe].flatten.filter [
			hasSignalbegriffID(Zs1) || hasSignalbegriffID(Zs7)
		].map[signalSignalbegriffAllg?.anschaltdauer?.wert].filterNull.toList

		switch (anschaltdauer) {
			case anschaltdauer.contains(ENUM_ANSCHALTDAUER_Z):
				return "Z"
			case anschaltdauer.contains(ENUM_ANSCHALTDAUER_T):
				return "T"
			default:
				return null
		}
	}

	private def String fillBemerkung(Signal signal,
		List<Signal_Rahmen> signalRahmen, TableRow row) {
		val bemerkungen = new LinkedList
		bemerkungen.addAll(
			signalRahmen.map[signalbegriffe].flatten.map [
				signalSignalbegriffAllg?.beleuchtet?.wert
			].filterNull.filter[it != ENUM_BELEUCHTET_NEIN].toSet.map[translate]
		)

		bemerkungen.addAll(
			signalRahmen.map[IDSignal?.value]?.flatMap[signalRahmen].map [
			signalBefestigung
		]?.map[IDBefestigungBauwerk?.value].filter(Technischer_Punkt).map [
			TPBeschreibung?.wert
		].filterNull.map [
			'''Befestigung an «it» '''
		])

		if (!signalRahmen.map[IDSignal?.value]?.flatMap[signalRahmen]?.map [
			rahmenHoehe?.wert
		].filterNull.empty) {
			bemerkungen.add("Rahmenhöhen beachten")
		}

		val commentStr = footnoteTransformation.transform(signal, row)

		if (commentStr !== null && commentStr.length > 0) {
			bemerkungen.add(commentStr)
		}
		return '''«FOR bemerkung : bemerkungen SEPARATOR ", "»«bemerkung»«ENDFOR»'''
	}

	private def double distance(
		Punkt_Objekt punktObjekt,
		Unterbringung unterbringung
	) {
		if (unterbringung.punktObjektTOPKante !== null) {
			val points = punktObjekt.singlePoints.map[new TopPoint(it)]
			val pb = new TopPoint(unterbringung.punktObjektTOPKante)
			return points.map[topGraphService.findShortestDistance(it, pb)].
				filter [
					present
				].map[get.doubleValue].min
		} else {
			val c1 = punktObjekt.coordinate
			val c2 = unterbringung.geoPunkt.coordinate
			return c1.distance(c2)
		}
	}

	private def void fillUeberhoehung(TableRow row, Signal signal) {
		val containerType = signal.container.containerType
		// Because find bank value process can take a long time,
		// therefore the bank column will be fill during find process.
		val threadName = '''«tableShortCut.toLowerCase»/Banking/«signal.cacheKey»'''
		new Thread([
			try {
				val bankValue = row.getUeberhoehung(signal).map [
					multiply(new BigDecimal(1000)).toTableInteger ?: ""
				]
				val changeProperties = new Pt1TableChangeProperties(
					containerType, row, cols.getColumn(Ueberhoehung), bankValue,
					ITERABLE_FILLING_SEPARATOR)
				val updateValuesEvent = new TableDataChangeEvent(
					tableShortCut.toLowerCase, changeProperties)
				// Send update event after find bank value process complete
				// or relevant bank value was found
				TableDataChangeEvent.sendEvent(eventAdmin, updateValuesEvent)
			} catch (InterruptedException exc) {
				Thread.currentThread.interrupt
			}
		], threadName).start
	}

	private def List<BigDecimal> getUeberhoehung(TableRow row,
		Signal signal) throws InterruptedException {
		val topPoint = new TopPoint(signal)
		var bankValue = bankingService.findBankValue(topPoint)
		// Fill Hourglass icon, when values is empty and find bank process still running.
		if (bankValue.isEmpty && !bankingService.isFindBankingComplete)
			fill(
				row,
				cols.getColumn(Ueberhoehung),
				signal,
				[
					CellContentExtensions.HOURGLASS_ICON
				]
			)
		// Get bank value again during the find bank process.
		while (bankValue.isNullOrEmpty) {
			bankValue = bankingService.findBankValue(topPoint)
			if (bankingService.isFindBankingComplete) {
				return bankValue
			}
			Thread.sleep(5000)
		}
		return bankValue
	}
}
