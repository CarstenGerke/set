/**
 * Copyright (c) 2019 DB Netz AG and others.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v2.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v20.html
 */
package org.eclipse.set.application.handler;

import org.eclipse.e4.core.di.annotations.CanExecute;
import org.eclipse.e4.core.di.annotations.Execute;
import org.eclipse.e4.core.di.annotations.Optional;

import org.eclipse.set.basis.IModelSession;

/**
 * Diese Steuerung kann geänderte Inhalte verwerfen.
 * 
 * @author Schaefer
 */
public class RevertHandler {

	@CanExecute
	private static boolean canExecute(@Optional final IModelSession session) {
		if (session != null) {
			return session.isDirty();
		}
		return false;
	}

	@Execute
	private static void execute(@Optional final IModelSession session) {
		if (session != null) {
			session.discardChanges();
		}
	}
}
