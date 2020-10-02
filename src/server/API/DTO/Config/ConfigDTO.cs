// Copyright (c) 2020, UW Medicine Research IT, University of Washington
// Developed by Nic Dobbins and Cliff Spital, CRIO Sean Mooney
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
using System;
using System.Linq;
using System.Collections.Generic;
using Model.Options;

namespace API.DTO.Config
{
    public class ConfigDTO
    {
        public AuthenticationConfigDTO Authentication { get; set; }
        public AttestationConfigDTO Attestation { get; set; }
        public CohortConfigDTO Cohort { get; set; }
        public ClientOptionsDTO Client { get;set; }
        public string Version { get; set; }
    }

    public class AuthenticationConfigDTO
    {
        public AuthenticationMechanism Mechanism { get; set; }
        public int InactivityTimeoutMinutes { get; set; }
        public string LogoutURI { get; set; }
    }

    public class CohortConfigDTO
    {
        public int CacheLimit { get; set; }
        public int ExportLimit { get; set; }
    }

    public class AttestationConfigDTO
    {
        public bool Enabled { get; set; }
    }

    public class ClientOptionsDTO
    {
        public MapOptionsDTO Map = new MapOptionsDTO();
        public VisualizeOptionsDTO Visualize = new VisualizeOptionsDTO();
        public PatientListOptionsDTO PatientList = new PatientListOptionsDTO();
        public HelpOptionsDTO Help = new HelpOptionsDTO();

        public class MapOptionsDTO
        {
            public bool Enabled { get; set; }
            public string TileURI { get; set; }
        }
        public class VisualizeOptionsDTO
        {
            public bool Enabled { get; set; }
            public bool ShowFederated { get; set; }
        }
        public class PatientListOptionsDTO
        {
            public bool Enabled { get; set; }
        }
        public class HelpOptionsDTO
        {
            public bool Enabled { get; set; }
            public AskQuestionOptionsDTO AskQuestion = new AskQuestionOptionsDTO();
            public DirectEmailOptionsDTO DirectEmail = new DirectEmailOptionsDTO();
            public WebsiteOptionsDTO Website = new WebsiteOptionsDTO();
            public ConsultOptionsDTO Consult = new ConsultOptionsDTO();

            public static HelpOptionsDTO From(ClientOptions.HelpOptions opts)
            {
                return new HelpOptionsDTO
                {
                    Enabled = opts.Enabled,
                    AskQuestion = new AskQuestionOptionsDTO
                    {
                        Enabled = opts.AskQuestion.Enabled,
                        LinkText = opts.AskQuestion.LinkText
                    },
                    DirectEmail = new DirectEmailOptionsDTO
                    {
                        Enabled = opts.DirectEmail.Enabled,
                        LinkText = opts.DirectEmail.LinkText,
                        Address = opts.DirectEmail.Address
                    },
                    Website = new WebsiteOptionsDTO
                    {
                        Enabled = opts.Website.Enabled,
                        LinkText = opts.Website.LinkText,
                        URI = opts.Website.URI
                    },
                    Consult = new ConsultOptionsDTO
                    {
                        Enabled = opts.Consult.Enabled,
                        LinkText = opts.Consult.LinkText,
                        WebHook = new ConsultOptionsDTO.WebHookOptionsDTO
                        {
                            Enabled = opts.Consult.WebHook.Enabled,
                            URI = opts.Consult.WebHook.URI
                        },
                        FormContent = new ConsultOptionsDTO.FormContentOptionsDTO
                        {
                            Title = opts.Consult.FormContent.Title,
                            Body = opts.Consult.FormContent.Body.Select(r => ConsultOptionsDTO.FormContentOptionsDTO.RecordOptions.From(r))
                        }
                    }
                };
            }

            public abstract class HelpMethodOptionsDTO
            {
                public bool Enabled { get; set; }
                public string LinkText { get; set; }
            }
            public class AskQuestionOptionsDTO : HelpMethodOptionsDTO { }
            public class DirectEmailOptionsDTO : HelpMethodOptionsDTO
            {
                public string Address { get; set; }
            }
            public class WebsiteOptionsDTO : HelpMethodOptionsDTO
            {
                public string URI { get; set; }
            }
            public class ConsultOptionsDTO : HelpMethodOptionsDTO
            {
                public WebHookOptionsDTO WebHook = new WebHookOptionsDTO();
                public FormContentOptionsDTO FormContent = new FormContentOptionsDTO();

                public class WebHookOptionsDTO
                {
                    public bool Enabled { get; set; }
                    public string URI { get; set; }
                }
                public class FormContentOptionsDTO
                {
                    public string Title { get; set; }
                    public IEnumerable<RecordOptions> Body = new List<RecordOptions>();

                    public class RecordOptions
                    {
                        public string Name { get; set; }
                        public string Type { get; set; }
                        public string[] Options { get; set; }

                        public static RecordOptions From(ClientOptions.HelpOptions.ConsultOptions.FormContentOptions.RecordOptions rec)
                        {
                            return new RecordOptions
                            {
                                Name = rec.Name,
                                Type = rec.Type,
                                Options = rec.Options
                            };
                        }
                    }
                }
            }
        }
    }
}
