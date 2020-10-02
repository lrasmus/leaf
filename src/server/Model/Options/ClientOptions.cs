// Copyright (c) 2020, UW Medicine Research IT, University of Washington
// Developed by Nic Dobbins and Cliff Spital, CRIO Sean Mooney
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
using System;
using System.Collections.Generic;

namespace Model.Options
{
    public class ClientOptions
    {
        public MapOptions Map = new MapOptions();
        public VisualizeOptions Visualize = new VisualizeOptions();
        public PatientListOptions PatientList = new PatientListOptions();
        public HelpOptions Help = new HelpOptions();

        public class MapOptions
        {
            public bool Enabled { get; set; }
            public string TileURI { get; set; }
        }
        public class VisualizeOptions
        {
            public bool Enabled { get; set; }
            public bool ShowFederated { get; set; }
        }
        public class PatientListOptions
        {
            public bool Enabled { get; set; }
        }
        public class HelpOptions
        {
            public bool Enabled { get; set; }
            public AskQuestionOptions AskQuestion = new AskQuestionOptions();
            public DirectEmailOptions DirectEmail = new DirectEmailOptions();
            public WebsiteOptions Website = new WebsiteOptions();
            public ConsultOptions Consult = new ConsultOptions();

            public abstract class HelpMethodOptions
            {
                public bool Enabled { get; set; }
                public string LinkText { get; set; }
            }
            public class AskQuestionOptions : HelpMethodOptions { }
            public class DirectEmailOptions : HelpMethodOptions
            {
                public string Address { get; set; }
            }
            public class WebsiteOptions : HelpMethodOptions
            {
                public string URI { get; set; }
            }
            public class ConsultOptions : HelpMethodOptions
            {
                public WebHookOptions WebHook = new WebHookOptions();
                public EmailOptions Email = new EmailOptions();
                public FormContentOptions FormContent = new FormContentOptions();

                public class WebHookOptions
                {
                    public bool Enabled { get; set; }
                    public string URI { get; set; }
                }
                public class EmailOptions
                {
                    public bool Enabled { get; set; }
                }
                public class FormContentOptions
                {
                    public string Title { get; set; }
                    public string Text { get; set; }
                    public ICollection<RecordOptions> Body = new List<RecordOptions>();

                    public class RecordOptions
                    {
                        public string Name { get; set; }
                        public bool Required { get; set; }
                        public string Type { get; set; }
                        public string[] Options { get; set; }
                    }
                }
            }
        }
    }
}
