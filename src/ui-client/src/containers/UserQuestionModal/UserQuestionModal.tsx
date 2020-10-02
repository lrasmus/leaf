/* Copyright (c) 2020, UW Medicine Research IT, University of Washington
 * Developed by Nic Dobbins and Cliff Spital, CRIO Sean Mooney
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */ 

import React from 'react';
import { HelpMethod, HelpState } from '../../models/state/GeneralUiState';
import { Modal } from 'reactstrap';
import { SavedQueryMap } from '../../models/Query';
import AskQuestionModal from './AskQuestionModal';
import { AuthorizationState } from '../../models/state/AppState';
import ConsultModal from './ConsultModal';
import './UserQuestionModal.css';

interface Props {
    auth?: AuthorizationState;
    dispatch: any;
    help: HelpState;
    queries: SavedQueryMap;
}

export default class UserQuestionModal extends React.PureComponent<Props> {
    private className = 'user-question-modal';

    public render() {
        const c = this.className;
        const { dispatch, queries, auth, help } = this.props;
        if (!auth || !auth.config || !auth.config.client.help) { return null; }

        const { show } = help;

        return (
            <Modal isOpen={show} className={`${c} leaf-modal`} keyboard={true} size={'lg'}>
                {/* Ask Question */}
                {help.method === HelpMethod.AskQuestion &&
                <AskQuestionModal dispatch={dispatch} queries={queries} help={help} />
                }

                {/* Request Consult */}
                {help.method === HelpMethod.Consult &&
                <ConsultModal dispatch={dispatch} queries={queries} help={help} consult={auth.config.client.help.consult} />
                }
            </Modal>
        );
    }
}