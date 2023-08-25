/**
 * Copyright (c) 2023 DB Netz AG and others.
 * 
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v2.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v20.html
 */
package org.eclipse.set.swtbot.table;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertInstanceOf;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Stream;

import org.eclipse.nebula.widgets.nattable.NatTable;
import org.eclipse.nebula.widgets.nattable.freeze.FreezeLayer;
import org.eclipse.nebula.widgets.nattable.grid.layer.GridLayer;
import org.eclipse.nebula.widgets.nattable.layer.ILayer;
import org.eclipse.set.utils.table.BodyLayerStack;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

/**
 * @author truong
 *
 */
class FixedColumnTest extends AbstractTableTest {
	@SuppressWarnings("boxing")
	private static Stream<Arguments> getPtTableToTestFixedColumn() {
		return PtTable.tablesToTest.stream()
				.filter(table -> table.fixedColumns().size() > 1
						|| table.fixedColumns().get(0) != 0)
				.map(table -> Arguments.of(table));
	}

	private FreezeLayer freezeLayer;

	private void thenExistFixedColumn() {
		final NatTable natTable = nattableBot.widget;
		final ILayer layer = natTable.getLayer();
		assertInstanceOf(GridLayer.class, layer);
		final GridLayer gridLayer = (GridLayer) layer;

		assertInstanceOf(BodyLayerStack.class, gridLayer.getBodyLayer());
		final BodyLayerStack bodyLayerStack = (BodyLayerStack) gridLayer
				.getBodyLayer();
		freezeLayer = bodyLayerStack.getFreezeLayer();
		assertNotNull(freezeLayer);
		assertTrue(freezeLayer.isFrozen());
	}

	private void thenFixedColumnsIsFixed(final List<Integer> fixedColumns) {
		int lastFixedColumn = 0;
		int firstFixedColumn = 0;
		if (fixedColumns.size() > 1) {
			final Set<Integer> cols = new HashSet<>();
			for (final int col : fixedColumns) {
				cols.add(Integer.valueOf(col));
			}
			lastFixedColumn = Collections.max(cols).intValue();
			firstFixedColumn = Collections.min(cols).intValue();
		}

		assertEquals(firstFixedColumn,
				freezeLayer.getTopLeftPosition().columnPosition);
		assertEquals(-1, freezeLayer.getTopLeftPosition().rowPosition);
		assertEquals(lastFixedColumn,
				freezeLayer.getBottomRightPosition().columnPosition);
		assertEquals(-1, freezeLayer.getBottomRightPosition().rowPosition);
	}

	@ParameterizedTest
	@MethodSource("getPtTableToTestFixedColumn")
	void testFixedColumn(final PtTable table) {
		givenNattableBot(table);
		thenExistFixedColumn();
		thenFixedColumnsIsFixed(table.fixedColumns());
	}
}