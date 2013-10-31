//
//  HCRDataSource.m
//  UNHCR
//
//  Created by Sean Conrad on 10/1/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRDataSource.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kRepeatUserUnder18 = @"Repeat Users < 18";
NSString *const kRepeatUserOver18 = @"Repeat Users ≥ 18";
NSString *const kDiscontinuedOver18 = @"Discontinued < 18";
NSString *const kDiscontinuedUnder18 = @"Discontinued ≥ 18";
NSString *const kQuantityDistributed = @"Quantity of each method distributed during period";

////////////////////////////////////////////////////////////////////////////////

@interface HCRDataSource ()

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRDataSource

+ (NSArray *)globalCampDataArray {
    
    return @[
             @{ @"Name": @"Iraq",
                @"Latitude": @34,
                @"Longitude": @44,
                @"Span": @1750000,
                @"Persons": @193631,
                @"Funding": @0.36,
                @"Camps": @[
                        [HCRDataSource _domizData],
                        @{@"Name": @"Erbil",
                          @"Latitude": @36.1995815,
                          @"Longitude": @44.0226888,
                          @"Span": @20000,
                          @"Persons": @67322},
                        @{@"Name": @"Suleimaniya",
                          @"Latitude": @35.5626992,
                          @"Longitude": @45.4365392,
                          @"Span": @20000,
                          @"Persons": @19693}]},
//             @{ @"Name": @"Turkey",
//                @"Persons": @494361,
//                @"Camps": @[
//                        @{@"Name": @""}
//                        ]},
//             @{ @"Name": @"Lebanon",
//                @"Persons": @773281,
//                @"Camps": @[
//                        @{@"Name": @""}
//                        ]},
//             @{ @"Name": @"Jordan",
//                @"Persons": @525231,
//                @"Camps": @[
//                        @{@"Name": @""}
//                        ]},
//             @{ @"Name": @"Egypt",
//                @"Persons": @126727,
//                @"Camps": @[
//                        @{@"Name": @""}
//                        ]},
             @{ @"Name": @"Uganda",
                @"Latitude": @1,
                @"Longitude": @32,
                @"Span": @1000000,
                @"Persons": @18253,
                @"Camps": @[
                        @{@"Name": @"Nakivale",
                          @"Latitude": @-0.6041135,
                          @"Longitude": @30.6517214,
                          @"Span": @10000,
                          @"Persons": @18253}]},
//             @{ @"Name": @"Kenya",
//                @"Persons": @474602,
//                @"Camps": @[
//                        @{@"Name": @""}
//                        ]},
//             @{ @"Name": @"Ethiopia",
//                @"Persons": @245068,
//                @"Camps": @[
//                        @{@"Name": @""}
//                        ]},
//             @{ @"Name": @"Yemen",
//                @"Persons": @230855,
//                @"Camps": @[
//                        @{@"Name": @""}
//                        ]},
//             @{ @"Name": @"Djibouti",
//                @"Persons": @18725,
//                @"Camps": @[
//                        @{@"Name": @""}
//                        ]},
//             @{ @"Name": @"Egypt",
//                @"Persons": @7957,
//                @"Camps": @[
//                        @{@"Name": @""}
//                        ]},
//             @{ @"Name": @"Eritrea",
//                @"Persons": @3468,
//                @"Camps": @[
//                        @{@"Name": @""}
//                        ]},
//             @{ @"Name": @"Tanzania",
//                @"Persons": @2103,
//                @"Camps": @[
//                        @{@"Name": @""}
//                        ]},
             @{ @"Name": @"Thailand",
                @"Latitude": @15,
                @"Longitude": @101.5,
                @"Span": @1500000,
                @"Persons": @140000,
                @"Camps": @[
                        @{@"Name": @"Umpiem Mai",
                          @"Latitude": @16.6047072,
                          @"Longitude": @98.6652615,
                          @"Span": @20000,
                          @"Persons": @17159}]}
             ];

}

+ (NSArray *)clusterLayoutMetaDataArray {
    
    // https://clusters.humanitarianresponse.info/sites/clusters.humanitarianresponse.info/files/clusterapproach.png
    // http://business.un.org/en/documents/249
    // http://www.unocha.org/what-we-do/coordination-tools/cluster-coordination
    
    return @[
             @{@"Name": @"Protection",
               @"Image": @"cluster-protection"},
             @{@"Name": @"Food Security",
               @"Image": @"cluster-food"},
             @{@"Name": @"Health",
               @"Image": @"cluster-health"},
             @{@"Name": @"Emergency Telecom",
               @"Image": @"cluster-telecoms"},
             @{@"Name": @"Camp Coordination",
               @"Image": @"cluster-coordination"},
             @{@"Name": @"Early Recovery",
               @"Image": @"cluster-recovery"},
             @{@"Name": @"Emergency Shelter",
               @"Image": @"cluster-shelter"},
             @{@"Name": @"Education",
               @"Image": @"cluster-education"},
             @{@"Name": @"Nutrition",
               @"Image": @"cluster-nutrition"},
             @{@"Name": @"Water/Sanitation",
               @"Image": @"cluster-water"},
             @{@"Name": @"Logistics",
               @"Image": @"cluster-logistics"}
             ];
}

+ (NSArray *)globalMessagesData {
    
    return @[
             @{@"From": @"Jesse Birns",
               @"Time": [[self _dateFormatterWithTime] stringFromDate:[self _randomTimeForNumberOfDaysAgo:0]],
               @"Message": @"Sounds great. Thank you!",
               @"Read": @NO},
             @{@"From": @"Ndola Prata",
               @"Time": [[self _dateFormatterWithRelativeDate] stringFromDate:[self _randomTimeForNumberOfDaysAgo:1]],
               @"Message": @"Sean - Please send the HIS tally sheet data to me by end of today. I need it for a research project that directly impacts our next funding cycle. Thank you!",
               @"Read": @YES},
             @{@"From": @"Emily Dakin",
               @"Time": [[self _dateFormatterWithRelativeDate] stringFromDate:[self _randomTimeForNumberOfDaysAgo:2]],
               @"Message": @"In case you didn't see it, don't drink the water in sector Q. I know you spend time down there in the evenings a lot.",
               @"Read": @YES},
             @{@"From": @"Antoine Grand",
               @"Time": [[self _dateFormatterWithRelativeDate] stringFromDate:[self _randomTimeForNumberOfDaysAgo:3]],
               @"Message": @"Sorry to interrupt, but can you come by the tent later? 4pm? It's quite urgent and I couldn't find you in your usual spot.",
               @"Read": @YES},
             @{@"From": @"Caterina Mecozzi",
               @"Time": [[self _dateFormatterWithRelativeDate] stringFromDate:[self _randomTimeForNumberOfDaysAgo:4]],
               @"Message": @"Ciao Sean. Grazie per il vostro aiuto ieri. Siamo davvero grati a UPP!",
               @"Read": @YES},
             @{@"From": @"Taban Lakonga",
               @"Time": [[self _dateFormatterWithRelativeDate] stringFromDate:[self _randomTimeForNumberOfDaysAgo:5]],
               @"Message": @"Come get some of that food later if you want. There's plenty.",
               @"Read": @YES},
             @{@"From": @"Chelsea Moore",
               @"Time": [[self _dateFormatterWithRelativeDate] stringFromDate:[self _randomTimeForNumberOfDaysAgo:6]],
               @"Message": @"A package arrived for you - I think it's that mobile phone you ordered. It's in Roger's tent in phase 6.",
               @"Read": @YES},
             @{@"From": @"Mike Pillinger",
               @"Time": [[self _dateFormatterWithRelativeDate] stringFromDate:[self _randomTimeForNumberOfDaysAgo:7]],
               @"Message": @"Your phone service is hooked up. You should get the handset tomorrow or the next day.",
               @"Read": @YES},
             @{@"From": @"Sarah Ireland",
               @"Time": [[self _dateFormatterWithRelativeDate] stringFromDate:[self _randomTimeForNumberOfDaysAgo:8]],
               @"Message": @"Those kids LOVED the pens you dropped by. THANK YOU!",
               @"Read": @YES},
             @{@"From": @"Dr Marzio Babille",
               @"Time": [[self _dateFormatterWithRelativeDate] stringFromDate:[self _randomTimeForNumberOfDaysAgo:9]],
               @"Message": @"Do you guys have any extra paper? Sarah's asking for some.",
               @"Read": @YES},
             @{@"From": @"Edrees Nabi Salih",
               @"Time": [[self _dateFormatterWithRelativeDate] stringFromDate:[self _randomTimeForNumberOfDaysAgo:10]],
               @"Message": @"Yes please.",
               @"Read": @YES},
             @{@"From": @"Tucker Cottingham",
               @"Time": [[self _dateFormatterWithRelativeDate] stringFromDate:[self _randomTimeForNumberOfDaysAgo:11]],
               @"Message": @"Really good to see you yesterday, my friend. See you in Geneva in March!",
               @"Read": @YES}
             ];
    
}

+ (NSArray *)globalEmergenciesData {
    return @[
             @{@"Country": @"Iraq",
               @"Camp": @"Domiz",
               @"Cluster": @"Health",
               @"Contact": @{@"Name": @"Edrees Nabi Salih",
                             @"Email": @"edress.salih@qandil.org",
                             @"Cluster": @"Education",
                             @"Agency": @"Quandil Iraq"},
               @"Alert": @"Half the kids I work with are suffering from severe diarrhea. Are others seeing the same?",
               @"Severity": @1,
               @"Time": [[self _dateFormatterWithRelativeDateAndTime] stringFromDate:[self _randomTimeForNumberOfDaysAgo:0]]},
             @{@"Country": @"Iraq",
               @"Camp": @"Domiz",
               @"Cluster": @"Water/Sanitation",
               @"Contact": @{@"Name": @"Dr Marzio Babille",
                             @"Phone": @"00962796111946",
                             @"Email": @"mbabille@unicef.org",
                             @"Cluster": @"Health",
                             @"Agency": @"UNICEF Iraq"},
               @"Alert": @"Contaminated water has been detected in sector Q. Do not drink the water. We will send another alert when it is resolved.",
               @"Severity": @1,
               @"Time": [[self _dateFormatterWithRelativeDateAndTime] stringFromDate:[self _randomTimeForNumberOfDaysAgo:1]]},
             @{@"Country": @"Iraq",
               @"Camp": @"Domiz",
               @"Cluster": @"Health",
               @"Contact": @{@"Name": @"Sarah Ireland",
                             @"Phone": @"00964 07710252207",
                             @"Email": @"sarah.ireland@savethechildren.org.au",
                             @"Cluster": @"Health",
                             @"Agency": @"SAVE Iraq"},
               @"Alert": @"My clinic is out of blood. Resupply won't be here until tomorrow. Can anyone take my patients today?",
               @"Severity": @1,
               @"Time": [[self _dateFormatterWithRelativeDateAndTime] stringFromDate:[self _randomTimeForNumberOfDaysAgo:5]]},
             @{@"Country": @"Iraq",
               @"Camp": @"Domiz",
               @"Cluster": @"Education",
               @"Contact": @{@"Name": @"Sarah Ireland",
                             @"Phone": @"00964 07710252207",
                             @"Email": @"sarah.ireland@savethechildren.org.au",
                             @"Cluster": @"Health",
                             @"Agency": @"SAVE Iraq"},
               @"Alert": @"Education providers are all unavailable today. Please redirect all inquiries to me in the mean time.",
               @"Severity": @1,
               @"Time": [[self _dateFormatterWithRelativeDateAndTime] stringFromDate:[self _randomTimeForNumberOfDaysAgo:8]]}
             ];
}

#pragma mark - Camps

+ (NSDictionary *)_domizData {
    
    // http://data.unhcr.org/
    
    return @{@"Name": @"Domiz",
             @"Latitude": @35.3923733,
             @"Longitude": @44.3757963,
             @"Span": @20000,
             @"Persons": @96272,
             @"SitReps": @"http://data.unhcr.org/syrianrefugees/documents.php?page=1&view=list&Language%5B%5D=1&Country%5B%5D=103&Type%5B%5D=2",
             @"Clusters": [HCRDataSource _iraqAgenciesData]
             };
}

#pragma mark - Health

+ (NSArray *)_healthTallySheetsArray {
    
    return @[
             [HCRDataSource _growthMonitoringTallySheet],
             [HCRDataSource _familyPlanningTallySheet],
             [HCRDataSource _tetanusToxoidTallySheet],
             [HCRDataSource _antenatalTallySheet]
             ];
    
}

+ (NSDictionary *)_familyPlanningTallySheet {
    return @{@"Name": @"Family Planning",
             @"Resources": @[
                     @{@"Title": @"COCP - low dose",
                       @"Subtitle": @"(Micro-gynon; Nordette)",
                       @"Unit": @"cycles"
                       },
                     @{@"Title": @"COCP - high dose",
                       @"Subtitle": @"(Lo-femenal)",
                       @"Unit": @"cycles"
                       },
                     @{@"Title": @"POP",
                       @"Subtitle": @"(Micro-val; Micro-lut)",
                       @"Unit": @"doses"
                       },
                     @{@"Title": @"ECP",
                       @"Subtitle": @"(Postinor-2)",
                       @"Unit": @"doses"
                       },
                     @{@"Title": @"Injectable",
                       @"Subtitle": @"(Depo-Provera)",
                       @"Unit": @"doses (ml)"
                       },
                     @{@"Title": @"Implantable",
                       @"Subtitle": @"(Norplant)",
                       @"Unit": @"implants"
                       },
                     @{@"Title": @"Intra-Uterine Device (IUD)",
                       @"Unit": @"IUDs"
                       },
                     @{@"Title": @"Condom (Male)",
                       @"Unit": @"pieces"
                       },
                     @{@"Title": @"Condom (Female)",
                       @"Unit": @"pieces"
                       },
                     @{@"Title": @"Sterilisation (Male)",
                       @"Unit": @"strerilisations",
                       @"Exclusions": @[
                               kRepeatUserOver18,
                               kRepeatUserUnder18,
                               kRepeatUserOver18,
                               kRepeatUserUnder18
                               ]
                       },
                     @{@"Title": @"Sterilisation (Female)",
                       @"Unit": @"strerilisations",
                       @"Exclusions": @[
                               kRepeatUserOver18,
                               kRepeatUserUnder18,
                               kRepeatUserOver18,
                               kRepeatUserUnder18
                               ]
                       },
                     @{@"Title": @"Other",
                       @"Exclusions": @[
                               kQuantityDistributed
                               ]
                       },
                     ],
             @"Questions": @[
                     @{@"Text": @"Cumulative number at start of period",
                       @"Lines": @2},
                     @{@"Text": @"New Users < 18"},
                     @{@"Text": @"New Users ≥ 18"},
                     @{@"Text": @"Repeat Users < 18"},
                     @{@"Text": @"Repeat Users ≥ 18"},
                     @{@"Text": @"Discontinued < 18"},
                     @{@"Text": @"Discontinued ≥ 18"},
                     @{@"Text": @"Cumulative number at end of period",
                       @"Lines": @2},
                     @{@"Text": @"Quantity of each method distributed during period",
                       @"Lines": @3},
                     ]};
}

+ (NSDictionary *)_growthMonitoringTallySheet {
    return @{@"Name": @"Growth Monitoring",
             @"Resources": @[
                     @{@"Title": @"Green",
                       @"Subtitle": @"(normal)"
                       },
                     @{@"Title": @"Yellow",
                       @"Subtitle": @"(borderline)"
                       },
                     @{@"Title": @"Red",
                       @"Subtitle": @"(danger)"
                       },
                     @{@"Title": @"Oedema"}
                     ],
             @"Questions": @[
                     @{@"Text": @"Refugee < 1"},
                     @{@"Text": @"Refugee ≥ 1 to < 5"}
                     ]};
}

+ (NSDictionary *)_tetanusToxoidTallySheet {
    return @{@"Name": @"Tetanus Toxoid",
             @"Resources": @[
                     @{@"Title": @"# doses of TT 1"},
                     @{@"Title": @"# doses of TT 2"},
                     @{@"Title": @"# doses of TT 3"},
                     @{@"Title": @"# doses of TT 4"},
                     @{@"Title": @"# doses of TT 5"}
                     ],
             @"Questions": @[
                     @{@"Text": @"Refugee Pregnant"},
                     @{@"Text": @"Refugee Non-Pregnant"},
                     @{@"Text": @"Other"}
                     ]};
}

+ (NSDictionary *)_antenatalTallySheet {
    return @{@"Name": @"Antenatal",
             @"Resources": @[
                     @{@"Title": @"first visits",
                       @"Subtitle": @"< 1st trimester"
                       },
                     @{@"Title": @"first visits",
                       @"Subtitle": @"> 1st trimester"
                       },
                     @{@"Title": @"repeat visits"},
                     @{@"Title": @"syphilis tests conducted"},
                     @{@"Title": @"syphilis tests positive"},
                     @{@"Title": @"syphilis positive contacts treated",
                       @"Lines": @2},
                     @{@"Title": @"high-risk pregnancies detected",
                       @"Lines": @2},
                     @{@"Title": @"abortions performed"},
                     @{@"Title": @"received 4 or more visits"},
                     @{@"Title": @"received 2 doses of tetanus toxoid vaccine",
                       @"Lines": @2},
                     @{@"Title": @"received at least 2 doses of fansidar",
                       @"Lines": @2},
                     @{@"Title": @"screened for syphilis"},
                     @{@"Title": @"received 2 doses of mebendazole",
                       @"Lines": @2},
                     @{@"Title": @"1 insecticide treated net (ITN)"}
                     ],
             @"Questions": @[
                     @{@"Text": @"Refugee < 18"},
                     @{@"Text": @"Refugee ≥ 18"}
                     ]};
}

#pragma mark - Iraq Agencies

+ (NSDictionary *)_iraqAgenciesData {
    return @{
             @"Protection": @{
                     @"Agencies": @[
                             [HCRDataSource _actedIraqData],
                             [HCRDataSource _harikarIraqData],
                             [HCRDataSource _icrcIraqData],
                             [HCRDataSource _ircIraqData],
                             [HCRDataSource _quandilIraqData],
                             [HCRDataSource _saveIraqData],
                             [HCRDataSource _unhcrIraqData],
                             [HCRDataSource _unicefIraqData]
                             ]
                     },
             @"Food Security": @{
                     @"Agencies": @[
                             [HCRDataSource _ddmIraqData],
                             [HCRDataSource _ircsIraqData],
                             [HCRDataSource _irwIraqData],
                             [HCRDataSource _modmIraqData],
                             [HCRDataSource _wfpIraqData]
                             ]
                     },
             @"Health": @{
                     @"Agencies": @[
                             [HCRDataSource _icrcIraqData],
                             [HCRDataSource _irwIraqData],
                             [HCRDataSource _modmIraqData],
                             [HCRDataSource _quandilIraqData],
                             [HCRDataSource _saveIraqData],
                             [HCRDataSource _unfpaIraqData],
                             [HCRDataSource _unhcrIraqData],
                             [HCRDataSource _unicefIraqData],
                             [HCRDataSource _uppIraqData],
                             [HCRDataSource _whoIraqData]
                             ],
                     @"SitReps": @"http://data.unhcr.org/syrianrefugees/documents.php?page=1&view=list&Language%5B%5D=1&Country%5B%5D=103&Type%5B%5D=2&Sector%5B%5D=3",
                     @"TallySheets": [HCRDataSource _healthTallySheetsArray]
                     },
             @"Emergency Telecom": @{
                     @"Agencies": @[
                             [HCRDataSource _unhcrIraqData]
                             ]
                     },
             @"Camp Coordination": @{
                     @"Agencies": @[
                             [HCRDataSource _actedIraqData],
                             [HCRDataSource _ddmIraqData],
                             [HCRDataSource _ircIraqData],
                             [HCRDataSource _irwIraqData],
                             [HCRDataSource _modmIraqData],
                             [HCRDataSource _quandilIraqData],
                             [HCRDataSource _unfpaIraqData],
                             [HCRDataSource _unhcrIraqData],
                             [HCRDataSource _unicefIraqData],
                             [HCRDataSource _uppIraqData],
                             [HCRDataSource _whoIraqData]
                             ]
                     },
             @"Early Recovery": @{
                     @"Agencies": @[
                             [HCRDataSource _unhcrIraqData]
                             ]
                     },
             @"Emergency Shelter": @{
                     @"Agencies": @[
                             [HCRDataSource _irwIraqData],
                             [HCRDataSource _ishoIraqData],
                             [HCRDataSource _modmIraqData],
                             [HCRDataSource _rirpIraqData],
                             [HCRDataSource _sbIraqData]
                             ]
                     },
             @"Education": @{
                     @"Agencies": @[
                             [HCRDataSource _iomIraqData],
                             [HCRDataSource _quandilIraqData],
                             [HCRDataSource _reachIraqData],
                             [HCRDataSource _unhcrIraqData],
                             [HCRDataSource _unicefIraqData],
                             [HCRDataSource _wfpIraqData]
                             ]
                     },
             @"Nutrition": @{
                     @"Agencies": @[
                             [HCRDataSource _unhcrIraqData],
                             [HCRDataSource _unicefIraqData],
                             [HCRDataSource _wfpIraqData]
                             ]
                     },
             @"Water/Sanitation": @{
                     @"Agencies": @[
                             [HCRDataSource _iomIraqData],
                             [HCRDataSource _irwIraqData],
                             [HCRDataSource _modmIraqData],
                             [HCRDataSource _quandilIraqData],
                             [HCRDataSource _rirpIraqData],
                             [HCRDataSource _unhcrIraqData],
                             [HCRDataSource _unicefIraqData]
                             ]
                     },
             @"Logistics": @{
                     @"Agencies": @[
                             [HCRDataSource _irwIraqData],
                             [HCRDataSource _ishoIraqData],
                             [HCRDataSource _modmIraqData],
                             [HCRDataSource _quandilIraqData],
                             [HCRDataSource _unhcrIraqData],
                             [HCRDataSource _uppIraqData],
                             [HCRDataSource _wfpIraqData]
                             ]
                     },
             };
}

+ (NSDictionary *)_modmIraqData {
    return @{@"Agency": @"Minsitry of Migration and Displacment",
             @"Abbr": @"MODM",
             @"About": @"The Minsitry of Migration and Displacment (MODM) is the official government body in Iraq that deals with the IDPs, Returnees and Refugees since it's establishment in 2004.",
             @"Contact": @{@"Name": @"Ammar Ali Juma'a",
                           @"Email": @"Stat73mang@gmail.com"},
             @"Website": @"http://momd.gov.iq/Default.aspx"};
}

+ (NSDictionary *)_ddmIraqData {
    return @{@"Agency": @"Directorate of Displacment and Migration",
             @"Abbr": @"DDM",
             @"About": @"Directorate of Displacment and Migration (DDM) mandate is concerned with providing basic needs of daily life, and make sure that the IDPs, Refugees, and Returnees, have access to all humanitarian needs.",
             @"Contact": @{@"Name": @"Mohammed M. Hamo",
                           @"Phone": @"7504502395",
                           @"Email": @"ddm.duhok@gmail.com"}};
}

+ (NSDictionary *)_unhcrIraqData {
    return @{@"Agency": @"United Nations High Commissioner For Refugees",
             @"Abbr": @"UNHCR Iraq"};
}

+ (NSDictionary *)_actedIraqData {
    return @{@"Agency": @"Agency for Technical Cooperation and Development",
             @"Abbr": @"ACTED Iraq",
             @"About": @"ACTED (Agency for Technical Cooperation and Development) is a non-governmental organization with headquarters in Paris, founded in 1993. Independent, private and not-for-profit, ACTED respects a... lire la suite",
             @"Contact": @{@"Name": @"Chelsea Moore",
                           @"Phone": @"+964 770 919 4774",
                           @"Email": @"chelsea.moore@acted.org"},
             @"Website": @"http://www.acted.org"};
}

+ (NSDictionary *)_ircIraqData {
    return @{@"Agency": @"International Rescue Committee",
             @"Abbr": @"IRC Iraq",
             @"About": @"The International Rescue Committee, one of the worldâ€™s leading humanitarian and post-conflict development agencies, provides relief, rehabilitation and reconstruction support to communities affected by war and natural disasters in over 40 countries.",
             @"Contact": @{@"Name": @"Emily Dakin",
                           @"Phone": @"00964 0770 426 2375",
                           @"Email": @"emily.dakin@rescue.org"},
             @"Website": @"http://www.rescue.org"};
}

+ (NSDictionary *)_icrcIraqData {
    return @{@"Agency": @"International Committee of the Red Cross",
             @"Abbr": @"ICRC Iraq",
             @"About": @"The ICRC has been present in Iraq since the outbreak of the Iran-Iraq war in 1980. Protection activities focus on people detained by Iraqi authorities, including Kurdistan regional authorities. ICRC delegates visit tens of thousands of detainees throughout the country, talk to them in private, and provide the relevant authorities with confidential feedback on the detaineesâ€™ treatment and living conditions. The visits also enable detainees to keep in touch with their loved ones, through Red Cross Messages, distributed in cooperation with the Iraqi Red Crescent Society to families in Iraq and abroad. The ICRC, in close cooperation with the respective governments, is also following the fate of thousands of missing persons as a result of the several conflicts in the region, and provides support and expertise in forensic medicine as well as in conducting joint excavation missions. Assistance activities, which focus on remote and neglected areas prone to violence, involve helping IDPs and residents restore their livelihood, with a focus on households headed by women, supporting primary health care centres and physical rehabilitation centres through the provision of material and training of medical personal and repairing and upgrading water, sanitation, health and detention infrastructure. The ICRC also continues to promote IHL among weapon bearers and to support the Iraqi Red Crescent Society in building up its capacities in the field of First Aid and Disaster Management. In a nutshell, in 2012 the ICRC: - further extended its operational out-reach into remote areas prone to violence in the centre of the country and the disputed territories; - conducted 231 visits to 109 places of detention holding approximately 38'161 detainees under Iraqi central or Kurdish authorities; - contributed to progress made in clarifying the fate of people missing as a result of the 1990-91 Gulf War and the 1980-88 Iran-Iraq War, facilitating seven joint operations to exhume and transfer human remains; - assisted 11'857 women heading household, amputees and farmer in rural areas prone to violence (with 57'513 dependents) with livelihood support projects, cash assistance and income-generating projects; - improved access to water, physical rehabilitation and primary health care for 1'844'522 residents, IDPs and returnees through the rehabilitation of water and health infrastructure, material support, training and coaching; - assisted 36'264 residents, refugees, IDPs and returnees with emergency assistance (food, non-food and water). - continued to provide, along with the International Federation, institutional support to the Iraqi Red Crescent.",
             @"Contact": @{@"Name": @"Antoine Grand",
                           @"Phone": @"00964 770-670-0825",
                           @"Email": @"agrand@icrc.org"},
             @"Website": @"http://www.icrc.org"};
}

+ (NSDictionary *)_irwIraqData {
    return @{@"Agency": @"Islamic Relief Worldwide",
             @"Abbr": @"IRW Iraq",
             @"About": @"Islamic Relief (IR) is an international relief and development charity which envisages a caring world where people unite to respond to the suffering of others, empowering them to fulfil their potential. We are an independent Non-Governmental Organisation (NGO) founded in the UK in 1984 . IRW Working in over 25 countries, we promote sustainable economic and social development by working with local communities to eradicate poverty, illiteracy and disease. We also respond to disasters and emergencies, helping people in crisis. Islamic Relief provides support regardless of religion, ethnicity or gender and without expecting anything in return.",
             @"Contact": @{@"Name": @"Mohammed Rafia",
                           @"Phone": @"00964 7801 97 65 63",
                           @"Email": @"mohammed.rafia@ir-iraq.org"},
             @"Website": @"http://www.islamic-relief.com"};
}

+ (NSDictionary *)_quandilIraqData {
    return @{@"Agency": @"Qandil, A Swedish Humanitarian Aid and Development Organization",
             @"Abbr": @"Quandil Iraq",
             @"Contact": @{@"Name": @"Edrees Nabi Salih",
                           @"Email": @"edress.salih@qandil.org"},
             @"Website": @"http://www.Qandil.org"};
}

+ (NSDictionary *)_saveIraqData {
    return @{@"Agency": @"Save the Children",
             @"Abbr": @"SAVE Iraq",
             @"Contact": @{@"Name": @"Sarah Ireland",
                           @"Phone": @"00964 07710252207",
                           @"Email": @"sarah.ireland@savethechildren.org.au"},
             @"Website": @"http://www.savethechildren.org"};
}

+ (NSDictionary *)_unicefIraqData {
    return @{@"Agency": @"United Nations Children's Fund",
             @"Abbr": @"UNICEF Iraq",
             @"Contact": @{@"Name": @"Dr Marzio Babille",
                           @"Phone": @"00962796111946",
                           @"Email": @"mbabille@unicef.org"},
             @"Website": @"http://www.unicef.org"};
}

+ (NSDictionary *)_uppIraqData {
    return @{@"Agency": @"Un Ponte Per",
             @"Abbr": @"UPP Iraq",
             @"About": @"UPP has been working in Iraq since 20 years and is currently implementing a program for assistance to Syrian refugees residing in Domiz Camp, together with its partner PAO, started a new action to allow a free psycho-social support provided to vulnerable Syrian women, children and men through individual and family counseling (including referring to the available psychological and social services available in the camp) Also, the project involves WASH and environment awareness - including provision of hygiene kits, orientation and guidance on available services in the area - including publication and distribution of a booklet containing all needed info and DDM staff training on SPHERE standards in emergency",
             @"Contact": @{@"Name": @"Caterina Mecozzi",
                           @"Email": @"caterina.mecozzi@unponteper.it"},
             @"Website": @"http://www.unponteper.it"};
}

+ (NSDictionary *)_whoIraqData {
    return @{@"Agency": @"World Health Organization",
             @"Abbr": @"WHO Iraq",
             @"Contact": @{@"Name": @"Dr. Jaffar Hussain",
                           @"Email": @"hussains@irq.emro.who.int"},
             @"Website": @"http://www.who.org"};
}

+ (NSDictionary *)_unfpaIraqData {
    return @{@"Agency": @"United Nations Population Fund",
             @"Abbr": @"UNFPA Iraq",
             @"About": @"UNFPA is an iternational development agency that promotes the rights of every women ,men and child to enjoy alife of health and equal apportunity .UNFPA supports countries in using population data for policies and programmes to reduce poverty and to ensure that every pregnancy is wanted, every birth is safe, every young person is free of HIV/AIDS, and every girl and woman is treated with dignity and respect.",
             @"Contact": @{@"Name": @"Radouane belouali",
                           @"Phone": @"009647901947439",
                           @"Email": @"belouali@unfpa.org"},
             @"Website": @"http://www.unfpa.org"};
}

+ (NSDictionary *)_harikarIraqData {
    return @{@"Agency": @"Harikar",
             @"Abbr": @"Harikar",
             @"About": @"Harikar is a neutral non-governmental humanitarian organization, which believes that in every aspect of life priority must be given to children and women. It commits itself to ensure particular protection for the very disadvantaged children and women, such as children who are born with chronic/abnormal diseases, disabled children, children with extreme poverty, victims of war and widows as well as woman headed families. Harikar assists in upgrading of the health service and promotion of technical cooperation, and â€“within the available resources- to promote/develop the infrastructure of the basic services. It also looks forward to participate- within its resources- in the process of rebuilding of the new Iraq. In close coordination with the other specialized agencies, Harikar assists in the improvement of nutrition, recreation, economic and other aspects of environmental hygiene. Harikar believes that education is a fundamental right and works towards its promotion; in this aspect, it strives towards ensuring basic education for all children irrespective of gender, religion, race and ethnicities. Harikar works with all national and international organizations as well as government bodies towards the realization of the sustainable human development objectives and contributes towards the achievement of the vision of piece and social progress.",
             @"Contact": @{@"Name": @"Salah. Y. Majid",
                           @"Phone": @"00964(0)7503404543",
                           @"Email": @"harikar_harikar@yahoo.com"},
             @"Website": @"http://www.harikar.org"};
}

+ (NSDictionary *)_ircsIraqData {
    return @{@"Agency": @"Iraqi Red Crescent Society",
             @"Abbr": @"IRCS",
             @"About": @"The association is humanitarian and indepndant , founded in 1932 and got an international approval in 1934 , and is bounded by all the items of the geneva conventions. Including the seven basic principles of the international movement of Red cross and Red Crescent societies.",
             @"Contact": @{@"Name": @"Talat Nashaat M. Shareef",
                           @"Phone": @"00964 07504471187",
                           @"Email": @"Duhok_ircs@yahoo.com"},
             @"Website": @"http://www.ircs.orq.iq"};
}

+ (NSDictionary *)_wfpIraqData {
    return @{@"Agency": @"World Food Programme",
             @"Abbr": @"WFP Iraq",
             @"About": @"WFP has been operating a range of food assistance programmes in Iraq since 1991. WFPâ€™s Syrian Refugee Emergency Operation is therefore able to capitalize on its experience assisting vulnerable populations in Iraq. In line with the interagency Regional Response Plan, WFP is providing food assistance up to 60,000 Syrian nationals in Iraq by December 2012. WFP is providing assistance in northern Iraq through the delivery of family food packages and is currently preparing to launch a voucher programme to beneficiaries in Domiz camp and to those living in local communities.",
             @"Contact": @{@"Name": @"Taban Lakonga",
                           @"Email": @"taban.lakonga@wfp.org"},
             @"Website": @"http://www.wfp.org"};
}

+ (NSDictionary *)_ishoIraqData {
    return @{@"Agency": @"Iraqi Salvation Humanitarian Organization",
             @"Abbr": @"ISHO Iraq",
             @"About": @"ISHO is an Iraqi registered NGO based in Iraq, that was established since 2003. It is aim to respond to the poor and suffering communities and organizations of a recovery Iraq. The work of ISHO is the delivery of humanitarian services to the people of Iraq. In addition to this aim, ISHO also actively seeks to enhance its services delivery by the development of its personnel and volunteers through training and personal growth. ISHO also aim to ensure sustainability of all its project implementation through coordination and cooperation with the authorities charged with care of potential beneficiaries. Among a number of objectives, ISHO continue to be a committed to finding funding from within and without Iraq in order to fulfill its humanitarian objectives.",
             @"Contact": @{@"Name": @"Muntajab Ibraheem Al Ruwaih",
                           @"Phone": @"00964 7801018111",
                           @"Email": @"muntajab_iraq@yahoo.com"}};
}

+ (NSDictionary *)_rirpIraqData {
    return @{@"Agency": @"Rebuild Iraq Reconstruction Program",
             @"Abbr": @"RIRP Iraq",
             @"Contact": @{@"Name": @"Nadine Flache",
                           @"Email": @"flache@rirp.org"},
             @"Website": @"http://www.rirp.org"};
}

+ (NSDictionary *)_sbIraqData {
    return @{@"Agency": @"ShelterBox",
             @"Abbr": @"ShelterBox Iraq",
             @"About": @"ShelterBox provides emergency shelter and lifesaving supplies for families around the world who are affected by disasters, at the time when they need it the most.",
             @"Contact": @{@"Email": @"ops@shelterbox.org"},
             @"Website": @"http://shelterbox.org"};
}

+ (NSDictionary *)_iomIraqData {
    return @{@"Agency": @"International Organization for Migration",
             @"Abbr": @"IOM Iraq",
             @"About": @"IOM Iraq provides emergency aid, non-food items, camp infrastructure support, and vocational training. Trained IOM teams provide psychological first aid to Syrians and migrants as needed. October 2012, IOM Rapid Response Teams (RRTs) carried out a comprehensive needs assessment of returnee and refugee populations in Iraq. With the assistance of the Slovakian Embassy IOM has also constructed a 21,000-liter water tank that provides clean water to all camp residents.. IOM Iraq’s assistance primarily concentrates in the governorates of Duhok and Anbar in addition to technical assistance in Ninewa with the development of a new camp in al Kasek.",
             @"Contact": @{@"Name": @"Mike Pillinger",
                           @"Phone": @"+962.797.344.430",
                           @"Email": @"mpillinger@iom.int"},
             @"Website": @"http://www.iomiraq.net/"};
}

+ (NSDictionary *)_reachIraqData {
    return @{@"Agency": @"Rehablitation, Education And Community's Health",
             @"Abbr": @"REACH",
             @"About": @"REACH is - A humanitarian, non-political and non-governmental Iraqi organization; - Independent and will remain so in order to preserve its own agenda based on its operational activities with communities in Iraq; - Working with marginalized and poor people throughout Iraq, to assist and support their efforts to make a difference to their lives.",
             @"Contact": @{@"Name": @"Saman Ahmed Majeed",
                           @"Phone": @"00964 0751155420",
                           @"Email": @"samana@reach-iraq.org"},
             @"Website": @"http://www.reach-iraq.org"};
}

#pragma mark - Private Methods

+ (NSDateFormatter *)_dateFormatterWithTime {
    return [NSDateFormatter dateFormatterWithFormat:HCRDateFormatHHmm forceEuropeanFormat:YES];
}

+ (NSDateFormatter *)_dateFormatterWithRelativeDate {
    return [NSDateFormatter dateFormatterWithFormat:HCRDateFormatSMSDates forceEuropeanFormat:YES];
}

+ (NSDateFormatter *)_dateFormatterWithRelativeDateAndTime {
    return [NSDateFormatter dateFormatterWithFormat:HCRDateFormatSMSDatesWithTime forceEuropeanFormat:YES];
}


+ (NSDate *)_randomTimeForNumberOfDaysAgo:(NSInteger)numberOfDays {
    
    NSInteger numberOfSecondsInOneDay = 60 * 60 * 24;
    NSTimeInterval randomTimeInOneDay = arc4random_uniform(numberOfSecondsInOneDay);
    
    return [[NSDate date] dateByAddingTimeInterval:(-1 * numberOfDays * numberOfSecondsInOneDay) - randomTimeInOneDay];
    
}

@end
