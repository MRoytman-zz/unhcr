//
//  HCRDataSource.m
//  UNHCR
//
//  Created by Sean Conrad on 10/1/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRDataSource.h"

////////////////////////////////////////////////////////////////////////////////

@interface HCRDataSource ()

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRDataSource

+ (NSArray *)globalDataArray {
    
    return @[
             @{@"Category": @"Syria Emergency",
               @"Countries": @[
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
                       @{ @"Name": @"Turkey",
                          @"Persons": @494361},
                       @{ @"Name": @"Lebanon",
                          @"Persons": @773281},
                       @{ @"Name": @"Jordan",
                          @"Persons": @525231},
                       @{ @"Name": @"Egypt",
                          @"Persons": @126727}
                       ]},
               
             @{@"Category": @"Horn of Africa",
               @"Countries": @[
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
                       @{ @"Name": @"Kenya",
                          @"Persons": @474602},
                       @{ @"Name": @"Ethiopia",
                          @"Persons": @245068},
                       @{ @"Name": @"Yemen",
                          @"Persons": @230855},
                       @{ @"Name": @"Djibouti",
                          @"Persons": @18725},
                       @{ @"Name": @"Egypt",
                          @"Persons": @7957},
                       @{ @"Name": @"Eritrea",
                          @"Persons": @3468},
                       @{ @"Name": @"Tanzania",
                          @"Persons": @2103}
                       ]},
             
             @{@"Category": @"Burmese Refugees",
               @"Countries": @[
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
                       ]}
             ];
             
}

+ (NSArray *)clusterImagesArray {
    
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

#pragma mark - Camps

+ (NSDictionary *)_domizData {
    
    // http://data.unhcr.org/
    
    return @{@"Name": @"Domiz",
             @"Latitude": @35.3923733,
             @"Longitude": @44.3757963,
             @"Span": @20000,
             @"Persons": @96272,
             @"SitReps": @"http://data.unhcr.org/syrianrefugees/documents.php?page=1&view=list&Language%5B%5D=1&Country%5B%5D=103&Type%5B%5D=2",
             @"Clusters": @{
                     @"Camp Coordination": @{
                             @"Agencies": @[
                                     [HCRDataSource _ddmIraqData],
                                     [HCRDataSource _modmIraqData],
                                     [HCRDataSource _unhcrIraqData],
                                     ]
                             },
                     @"Health": @{
                             @"Agencies": @[
                                     [HCRDataSource _icrcIraqData],
                                     [HCRDataSource _irwIraqData],
                                     [HCRDataSource _modmIraqData],
                                     [HCRDataSource _quandilIraqData]
                                     ],
                             @"SitReps": @"http://data.unhcr.org/syrianrefugees/documents.php?page=1&view=list&Language%5B%5D=1&Country%5B%5D=103&Type%5B%5D=2&Sector%5B%5D=3",
                             @"TallySheets": @YES
                             },
                     
                     },
             };
}

#pragma mark - Iraq Agencies

+ (NSDictionary *)_modmIraqData {
    return @{@"Agency": @"Minsitry of Migration and Displacment",
             @"Abbr": @"MODM",
             @"About": @"The Minsitry of Migration and Displacment (MODM) is the official government body in Iraq that deals with the IDPs, Returnees and Refugees since it's establishment in 2004.",
             @"Contact": @{@"Name": @"Ammar Ali Juma'a",
                           @"Email": @"Stat73mang@gmail.com"},
             @"Website": @"http://momd.gov.iq/Default.aspx"};
}

#pragma mark - Camp Coordination

+ (NSDictionary *)_ddmIraqData {
    return @{@"Agency": @"Directorate of Displacment and Migration",
             @"Abbr": @"DDM",
             @"About": @"Directorate of Displacment and Migration (DDM) mandate is concerned with providing basic needs of daily life, and make sure that the IDPs, Refugees, and Returnees, have access to all humanitarian needs.",
             @"Contact": @{@"Name": @"Mohammed M. Hamo",
                           @"Phone": @"7504502395",
                           @"Email": @"ddm.duhok@gmail.com"}};
}

+ (NSDictionary *)_unhcrIraqData {
    return @{@"Agency": @"United Nations High Commissioner For Refugees Iraq",
             @"Abbr": @"UNHCR Iraq"};
}

#pragma mark - Health

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

@end
