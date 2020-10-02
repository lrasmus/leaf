// Copyright (c) 2020, UW Medicine Research IT, University of Washington
// Developed by Nic Dobbins and Cliff Spital, CRIO Sean Mooney
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
using System;

namespace API.Options
{
    public partial class Config
    {
        public static class Client
        {
            public static class Map
            {
                public const string Section = @"Client:Map";
                public const string Enabled = @"Client:Map:Enabled";
                public const string TileURI = @"Client:Map:TileURI";
            }
            public static class Visualize
            {
                public const string Section = @"Client:Visualize";
                public const string Enabled = @"Client:Visualize:Enabled";
                public const string ShowFederated = @"Client:Visualize:ShowFederated";
            }
            public static class PatientList
            {
                public const string Section = @"Client:PatientList";
                public const string Enabled = @"Client:PatientList:Enabled";
            }
            public static class Help
            {
                public const string Section = @"Client:Help";
                public const string Enabled = @"Client:Help:Enabled";

                public static class AskQuestion
                {
                    public const string Enabled = @"Client:Help:AskQuestion:Enabled";
                    public const string LinkText = @"Client:Help:AskQuestion:LinkText";
                }
                public static class DirectEmail
                {
                    public const string Enabled = @"Client:Help:DirectEmail:Enabled";
                    public const string Address = @"Client:Help:DirectEmail:Address";
                    public const string LinkText = @"Client:Help:DirectEmail:LinkText";
                }
                public static class Website
                {
                    public const string Enabled = @"Client:Help:Website:Enabled";
                    public const string URI = @"Client:Help:Website:URI";
                    public const string LinkText = @"Client:Help:Website:LinkText";
                }
                public static class Consult
                {
                    public const string Section = @"Client:Help:Consult";
                    public const string Enabled = @"Client:Help:Consult:Enabled";
                    public const string LinkText = @"Client:Help:Consult:LinkText";

                    public static class Webhook
                    {
                        public const string Section = @"Client:Help:Consult:Webhook";
                        public const string Enabled = @"Client:Help:Consult:Webhook:Enabled";
                        public const string URI = @"Client:Help:Consult:Webhook:URI";
                    }
                    public static class Email
                    {
                        public const string Section = @"Client:Help:Consult:Email";
                        public const string Enabled = @"Client:Help:Consult:Email:Enabled";
                    }
                    public static class FormContent
                    {
                        public const string Section = @"Client:Help:Consult:FormContent";
                        public const string Title = @"Client:Help:Consult:FormContent:Title";
                        public const string Body = @"Client:Help:Consult:FormContent:Body";

                        public static class Record
                        {
                            public const string Name = @"Name";
                            public const string Type = @"Type";
                            public const string Options = @"Options";
                        }
                    }
                }
            }
        }
    }
}
