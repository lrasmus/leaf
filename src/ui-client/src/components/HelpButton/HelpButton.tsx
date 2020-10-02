/* Copyright (c) 2020, UW Medicine Research IT, University of Washington
 * Developed by Nic Dobbins and Cliff Spital, CRIO Sean Mooney
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */ 

import React from 'react';
import { setHelpState, toggleHelpModal } from '../../actions/generalUi';
import { AuthorizationState } from '../../models/state/AppState';
import { MdTagFaces } from 'react-icons/md';
import { HelpMethod, HelpState } from '../../models/state/GeneralUiState';
import './HelpButton.css';

interface Props {
    auth?: AuthorizationState;
    dispatch: any;
    help: HelpState;
}

export default class HelpButton extends React.PureComponent<Props> {
    private className = 'help';

    public render() {
        const { auth } = this.props;
        const c = this.className;
        if (!auth || !auth.config || !auth.config.client.help.enabled) { return null; }
        const { help } = auth.config.client;

        const opts = [];
        if (help.askQuestion.enabled) opts.push(this.getFunctionalLink(help.askQuestion.linkText, this.handleAskQuestionClick));
        if (help.directEmail.enabled) opts.push(this.getDirectEmail());
        if (help.website.enabled)     opts.push(this.getWebsite());
        if (help.consult.enabled)     opts.push(this.getFunctionalLink(help.consult.linkText, this.handleRequestConsultClick));

        const toRender = [];
        for (let i = 0; i < opts.length; i++) {
            toRender.push(<span className={`${c}-option`} key={i}>{opts[i]}</span>);
            if (i < opts.length-1) {
                toRender.push(<span className={`${c}-or`} key={i}>or</span>);
            }
        }

        return (
            <div className={`${c}-container`}>
                <div className={`${c}-icon-container`}>
                    <MdTagFaces />
                </div>
                <div className={`${c}-needhelp`}>Need Help?</div>
                <div className={`${c}-outer`}>
                    <div className={`${c}-inner`}>
                        {toRender}
                    </div>
                </div>
            </div>
        )
    }

    private getFunctionalLink = (text: string, onClick: any) => {
        return (
            <a onClick={onClick}>
                {text}
            </a>
        );
    }

    private getDirectEmail = () => {
        const { directEmail } = this.props.auth!.config!.client.help!;
        return (
            <a href={`mailto:${directEmail.address}`}>
                {directEmail.linkText}
            </a>
        );
    }

    private getWebsite = () => {
        const { website } = this.props.auth!.config!.client.help!;
        return (
            <a href={website.uri} target="_">
                {website.linkText}
            </a>
        );
    }

    private handleAskQuestionClick = () => {
        const { dispatch, help } = this.props;
        dispatch(setHelpState({ ...help, show: true, method: HelpMethod.AskQuestion }));
    }

    private handleRequestConsultClick = () => {
        const { dispatch, help } = this.props;
        dispatch(setHelpState({ ...help, show: true, method: HelpMethod.Consult }));
    }
}