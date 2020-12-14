/* Copyright (c) 2020, UW Medicine Research IT, University of Washington
 * Developed by Nic Dobbins and Cliff Spital, CRIO Sean Mooney
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */ 

import React from 'react';
import { HelpState } from '../../models/state/GeneralUiState';
import { ModalHeader, ModalBody, ModalFooter, Button, Row, Col, FormGroup, Label, FormText, Input, Dropdown, DropdownToggle, DropdownMenu, DropdownItem, Form } from 'reactstrap';
import { SavedQueryMap } from '../../models/Query';
import { ConsultOptions, FormContentRecord, FormContentRecordType } from '../../models/Auth';
import { setHelpState, toggleHelpModal } from '../../actions/generalUi';

interface Props {
    consult: ConsultOptions;
    dispatch: any;
    help: HelpState;
    queries: SavedQueryMap;
}

interface State {
    dropdownsOpen: boolean[];
}

export default class ConsultModal extends React.PureComponent<Props,State> {
    private className = 'user-question-modal';

    public constructor(props: Props) {
        super(props);
        this.state = {
            dropdownsOpen: this.props.help.consult.answers.map((x) => false)
        }
    }

    public render() {
        const c = this.className;
        const { webHook, formContent } = this.props.consult;
        const { answers } = this.props.help.consult;

        return (
            <div>
                {/* Header */}
                <ModalHeader>
                    {formContent.title} <span className={`${c}-close`} onClick={this.handleCloseClick}>✖</span>
                </ModalHeader>

                {/* Body */}
                <ModalBody>
                    <div className={`${c}-consult-toptext`}>
                        {formContent.text}
                    </div>
                        <div className={`${c}-consult-body`}>
                        {formContent.body.map((rec,i) => {
                            if (rec.type === FormContentRecordType.text) { 
                                return this.getTextField(i, rec, answers[i], 'text'); 
                            } else if (rec.type === FormContentRecordType.textarea) {
                                return this.getTextField(i, rec, answers[i], 'textarea'); 
                            } else {
                                return this.getDropdownField(i, rec, answers[i]);
                            }
                        })}
                    </div>
                </ModalBody>

                {/* Footer */}
                <ModalFooter>
                    <Button className="leaf-button leaf-button-primary" onClick={this.handleCloseClick}>Close</Button>
                    <Button className="leaf-button leaf-button-addnew">Request Consult</Button>
                </ModalFooter>
            </div>
        );
    }

    private getTextField = (i: number, rec: FormContentRecord, text: string, type: 'text' | 'textarea') => {
        const c = this.className;
        return (
            <Row key={i}>
                <Col md={12}>
                    <div className={`${c}-section`}>
                        <FormGroup className={`${c}-question`}>
                            <Label>
                               {rec.name}
                            </Label>
                            <Input
                                className={'leaf-input'}
                                onChange={this.handleTextAnswerChange.bind(null, i)}
                                readOnly={false}
                                spellCheck={false}
                                type={type}
                                value={text} />
                        </FormGroup>
                    </div>
                </Col>
            </Row>
        );
    }

    private getDropdownField = (i: number, rec: FormContentRecord, text: string) => {
        const c = this.className;
        const { dropdownsOpen } = this.state;
        return (
            <Row key={i}>
                <Col md={12}>
                    <div className={`${c}-section`}>
                        <FormGroup>
                            <Label>
                                {rec.name}
                            </Label>
                            <div className={`${c}-dropdown`} tabIndex={0}>
                                <Dropdown isOpen={dropdownsOpen[i]} toggle={this.toggleDropdown.bind(null, i)} >
                                    <DropdownToggle>
                                        {!text  ? 'Select a value' : text}
                                    </DropdownToggle>
                                    <DropdownMenu>
                                        <div className={`${c}-dropdown-item-container`}>
                                        {rec.options!.map((q,j) => {
                                            return (
                                                <DropdownItem 
                                                    key={j} onClick={this.handleDropdownAnswerChange.bind(null, i, q)}
                                                    className={text === q ? 'selected' : ''}>
                                                    {q}
                                                </DropdownItem>
                                            );
                                        })}
                                        </div>
                                    </DropdownMenu>
                                </Dropdown>
                            </div>
                        </FormGroup>
                    </div>
                </Col>
            </Row>
        );
    }

    private toggleDropdown = (i: number) => {
        const newdd = this.state.dropdownsOpen.slice();
        newdd[i] = !newdd[i];
        this.setState({ dropdownsOpen: newdd });
    }

    private handleDropdownAnswerChange = (i: number, text: string) => {
        const { dispatch, help } = this.props;
        const newAnswers = help.consult.answers.slice();
        newAnswers[i] = text;
        dispatch(setHelpState({ ...help, consult: { ...help.consult, answers: newAnswers }}));
    }

    private handleTextAnswerChange = (i: number, e: React.ChangeEvent<HTMLInputElement>) => {
        const { dispatch, help } = this.props;
        const newAnswers = help.consult.answers.slice();
        newAnswers[i] = e.currentTarget.value;
        dispatch(setHelpState({ ...help, consult: { ...help.consult, answers: newAnswers }}));
    }

    private handleCloseClick = () => {
        const { dispatch } = this.props;
        dispatch(toggleHelpModal());
    }
}