/* Copyright (c) 2020, UW Medicine Research IT, University of Washington
 * Developed by Nic Dobbins and Cliff Spital, CRIO Sean Mooney
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */ 
import { HttpFactory } from './HttpFactory';
import { HelpState } from '../models/state/GeneralUiState';
import { AppState } from '../models/state/AppState';

export const sendUserInquiry = async (state: AppState, inquiry: HelpState): Promise<boolean> => {
    const { token } = state.session.context!;
    const http = HttpFactory.authenticated(token);
    const request = await http.post('/api/notification/inquiry', { 
        associatedQueryId: inquiry.askQuestion.associatedQuery ? inquiry.askQuestion.associatedQuery.universalId : null,
        emailAddress: inquiry.askQuestion.email,
        type: inquiry.askQuestion.type,
        text: inquiry.askQuestion.text
    });
    return request.data as boolean;
};
