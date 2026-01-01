Софтпанорама 1993, No.1 (35)  *** NEWS ***   Составитель: Н.Н. БЕЗРУКОВ
************************************************************************

                 ╔═════════════════════════════════════╗
                 ║  П А Н О Р А М А   Н О В О С Т Е Й  ║
                 ╚═════════════════════════════════════╝

**************************  КРАТКАЯ ИHФОРМАЦИЯ *************************

******************  НОВОГОДНИЙ ПОДАРОК ФИРМЫ PKWARE ******************** 
**** PKZIP 2.04 - НОВЫЙ ЛИДЕР ПО СКОРОСТИ РАБОТЫ СРЕДИ АРХИВАТОРОВ *****

      PkZip 2.04 существенно быстрее Arj 2.39 и дает лишь немного 
 худшие результаты при существенно (примерно на треть) меньшем времени
 упаковки !!!
      На упаковке EXE-файлов он выглядит чуть хуже. Впрочем на некоторых
 наборах файлов он выигрывает у arj (см. ниже).
      На смешанном материале c преобладанием текста (выпуск А бюллетеня)
 он проигрывает ARJ примерно 15K (arj - 724K, pkzip - 740K)
      Похоже, что PKZIP 1.93a ноpмально pаспаковывает аpхивы созданные 
 новой версией! Видимо, фоpмат остался практически пpежним, хотя сам 
 алгоpитм стал немного быстpее.
      Как и предыдущие версии программа требует чуть больше 80K
 того меньше) и хорошо работает под DV, а все "конфликтоспособные" для
 возможности (кривое EMS и др. проблемы) отключаются ключиками.

    Некоторые результаты тестирования приведены ниже.

 Sender: L-usenet@river.cs.kiev.ua
 Newsgroups: comp.compression
 From: djtooley@undergrad.math.waterloo.edu (Doug Tooley)
 Subject: [NEWS] PKZIP 2.04c  vs.  ARJ/LHA/ZOO   Compression/Speed Results
 Message-ID: <C0IDt1.Iz2@undergrad.math.waterloo.edu>
 Organization: University of Waterloo
 Date: Fri, 8 Jan 1993 00:10:13 GMT
 Lines: 97
 Status: RO

 Results of Compression Testing: PKZIP 2.04c          Jan 06/92

 Data:       Contents of ARJ230.EXE and PKZ204C.EXE
                       (with duplicate filenames renamed/included)
 Total Size: 720937 bytes
 Archivers:  PKZIP204c PKZIP110 PKZIP193a ARJ230 LHA213 ZOO210
 Machine:    386/33, 10M RAM  \w 128k BIOS Shadow RAM
 Drive:      Seagate ST296N (84M)  SCSI controller   (no s/w cache)
 Timing:     Norton Utilities'  TM.EXE  v4.50
 Execution:  MSDOS BATch file

 Results:

  TIME    FILENAME        SIZE      COMMAND

 Sorted by Size

 27 secs  ZIP204X  ZIP    358090    pkzip -ex
 55 secs  ARJ230JM ARJ    359725    arj a -jm
 23 secs  ZIP204   ZIP    360153    pkzip
 21 secs  ZIP204N  ZIP    360153    pkzip -en
 47 secs  ARJ230   ARJ    360228    arj a
 48 secs  ARJ230M1 ARJ    360230    arj a -m1
 22 secs  ZIP193   ZIP    362995    pkzip
 44 secs  ARJ230M2 ARJ    363519    arj a -m2
 48 secs  LHA213   LZH    368780    lha a
 19 secs  ZIP204F  ZIP    369940    pkzip -ef
 94 secs  ZOO210H  ZOO    370481    zoo ah
 35 secs  ARJ230M3 ARJ    371169    arj a -m3
 26 secs  ZIP110   ZIP    381182    pkzip
 15 secs  ZIP204S  ZIP    393321    pkzip -es
 69 secs  ZOO210   ZOO    459204    zoo a
 24 secs  ARJ230M0 ARJ    723239    arj a -m0
 14 secs  ZIP2040  ZIP    724559    pkzip -e0

 Sorted by Time

 14 secs  ZIP2040  ZIP    724559    pkzip -e0
 15 secs  ZIP204S  ZIP    393321    pkzip -es
 19 secs  ZIP204F  ZIP    369940    pkzip -ef
 21 secs  ZIP204N  ZIP    360153    pkzip -en
 22 secs  ZIP193   ZIP    362995    pkzip
 23 secs  ZIP204   ZIP    360153    pkzip
 24 secs  ARJ230M0 ARJ    723239    arj a -m0
 26 secs  ZIP110   ZIP    381182    pkzip
 27 secs  ZIP204X  ZIP    358090    pkzip -ex
 35 secs  ARJ230M3 ARJ    371169    arj a -m3
 44 secs  ARJ230M2 ARJ    363519    arj a -m2
 47 secs  ARJ230   ARJ    360228    arj a
 48 secs  ARJ230M1 ARJ    360230    arj a -m1
 48 secs  LHA213   LZH    368780    lha a
 55 secs  ARJ230JM ARJ    359725    arj a -jm
 69 secs  ZOO210   ZOO    459204    zoo a
 94 secs  ZOO210H  ZOO    370481    zoo ah

 Sorted by Name  (for the scroll-back impaired)

 47 secs  ARJ230   ARJ    360228    arj a
 55 secs  ARJ230JM ARJ    359725    arj a -jm
 24 secs  ARJ230M0 ARJ    723239    arj a -m0
 48 secs  ARJ230M  ARJ    360230    arj a -m1
 44 secs  ARJ230M2 ARJ    363519    arj a -m2
 35 secs  ARJ230M3 ARJ    371169    arj a -m3
 48 secs  LHA213   LZH    368780    lha a
 26 secs  ZIP110   ZIP    381182    pkzip
 22 secs  ZIP193   ZIP    362995    pkzip
 23 secs  ZIP204   ZIP    360153    pkzip
 14 secs  ZIP2040  ZIP    724559    pkzip -e0
 19 secs  ZIP204F  ZIP    369940    pkzip -ef
 21 secs  ZIP204N  ZIP    360153    pkzip -en
 15 secs  ZIP204S  ZIP    393321    pkzip -es
 27 secs  ZIP204X  ZIP    358090    pkzip -ex
 69 secs  ZOO210   ZOO    459204    zoo a
 94 secs  ZOO210H  ZOO    370481    zoo ah
                                 * * *

********** Киевская секция ACM SIGMOD выходит из подполья **************
 и вместе с аналогичной Московской секцие собирается провести семинар
    ПЕРСПЕКТИВЫ РАЗВИТИЯ СИСТЕМ БАЗ ДАННЫХ И ИНФОРМАЦИОННЫХ СИСТЕМ
                              ADBIS'93
                      Предварительное сообщение
                Первый объединенный Рабочий семинар
              Киевской и Московской секций ACM SIGMOD
                    Протвино, 11-14 мая 1993 г.

 ADBIS'93 открывает  серию  ежегодных  рабочих семинаров по перспективным
 направлениям исследований и разработок в области систем баз данных и ин-
 формационных системах, проведение которых планируется совместно Киевской
 и Московской секциями ACM SIGMOD.

 Для включения в программу Рабочего семинара следует представить один эк-
 земпляр  расширенных тезисов доклада объемом не более 1000 слов не позд-
 нее 1 марта 1993 г. Тезисы должны содержать краткое содержание предпола-
 гаемого доклада.  Полные  тексты  статей  в репродуцируемой форме должны
 быть представлены к началу семинара и после дополнительного рецензирова-
 ния будут опубликованы.

 Количество участников ограничено.  Предполагается участие 40-50 активных
 исследователей, работающих в области баз данных и информационных систем.
 Как правило,  участие в семинире предполагает  выступление  с  докладом,
 описывающим результаты научно-исследовательских работ.

 На семинаре  предполагается  обсуждать  работы,  содержащие оригинальные
 идеи,  новые исследовательские и экспериментальные результаты в  области
 баз  данных и информационных систем.  Возможные темы работ определяются,
 но не ограничиваются следующим обширным перечнем:
      Активные базы данных
      Управление параллельным доступом и средства восстановления
      Поддержка ограничений
      Модели данных
      Проектирование баз данных
      Языки программирования баз данных
      Дедуктивные базы данных
      Распределенные системы баз данных
      Федеративные системы/мультибазы данных
      Базы данных для систем автоматизированного проектирования
      Неоднородные системы баз данных
      Базы данных с неполной и неопределенной информацией
      Целостность и безопасность
      Извлечение знаний из баз данных
      Представление знаний
      Вопросы интероперабельности систем мультибаз данных
      Модели мультитранзакций и языки спецификаций
      Объектно-ориентированные системы баз данных
      Параллельные архитектуры
      Языки запросов
      Научные базы данных и приложения
      Анализ и интеграция схем

                    ПРОГРАММНЫЙ КОМИТЕТ СЕМИНАРА
      Сопредседатель от                      Сопредседатель от
  Киевской секции ACM SIGMOD            Московской секции ACM SIGMOD
         СТОГНИЙ А.А.                         КАЛИНИЧЕНКО Л.А.
 Институт прикладной информатики      Институт проблем информатики РАН
       252004, Киев-4                      117900, Москва, В-342
  ул.Красноармейская, 23-б                   ул.Вавилова, 30/6
    тел. (044) 225-60-64                    тел. (095) 237-20-31
 e-mail: astog@astog.sytech.kiev.ua   e-mail:leonidk@ipian15.ipian.msk.su

                     Члены программного комитета
                Азаров С.С.          Когаловский М.Р.
                Вольфенгаген В.Э.    Кузнецов С.Д.
                Емельянов Н.Е.       Новиков Б.А.
                Клименко С.В.        Столяров Г.К.

 ВАЖНЫЕ ДАТЫ:
     Представление расширенных тезисов:    1 марта 1993 г.
     Извещение о принятии или отклонении: 30 марта 1993 г.
                                 * * *


**************** Международный семинар-выставка *************************
************* по свободному системному и прикладному ********************
************ программному обеспечению в среде ОС UNIX *******************

       "THE WORKSHOP FOR FREE SYSTEM AND APLICATION SOFTWARE
                      IN UNIX ENVIRONMENT"
                   (Moscow, April 20-24, 1993)


      С 20  по 24 апреля 1993 года в городе Москве в Международном
 центре  научной  и  технической  информации  (МЦНТИ)   ассоциация
 пользователей   операционной  системы  UNIX  (SUUG)  совместно  с
 Российским центром системного программирования и  МЦНТИ  проводит
 международный семинар-выставку   по   свободному   системному   и
 прикладному программному в среде UNIX.

      На семинаре предполагается:
 - рассмотреть     вопросы     текущего     состояния     свободно
 распространяемого   программного   обеспечения,   перспектив  его
 развития и    использования    для     нужд     производственных,
 исследовательских и учебных организаций,
 - продемонстрировать   возможности,    доступные    пользователям
 свободного программного обеспечения,
 - обсудить перспективные  технологии  по  разработке  прикладного
 программного обеспечения в среде UNIX.

      На семинар приглашены ряд ведущих специалистов  из FSF (Free
 Software  Foundation),  Европейского   форума   Открытых   Систем
 (EurOpen),   ассоциации  Usenix  (США)  и  UNIFORUM.  Выставка  с
 презентацией различных аппаратных и программных продуктов ведущих
 зарубежных  и  отечественных  фирм разработчиков и производителей
 средств  вычислительной  техники  (предполагается   участие   Sun
 Microsystems,  Unix System Laboratories, HP, Data General и т.д.)
 предоставит возможность познакомиться с новейшими разработками  в
 среде  UNIX.  В  рамках  семинара  будет проведено общее собрание
 членов ассоциации пользователей операционной системы UNIX.
      В период  работы  семинара-выставки будет доступно свободно-
 распространяемое программное обеспечение (по цене копирования).

                       УЧАСТИЕ В СЕМИНАРЕ

 Участие в семинаре возможно в качестве докладчиков и  слушателей.
 Кроме  того,  в ходе семинара будут проведены панельные дискуссии
 по  наиболее  интересным   темам.   Предусмотрены   условия   для
 продуктивного  общения  специалистов.  Участники  семинара  могут
 провести демонстрацию на ЭВМ своих разработок, принимаются заявки
 на  размещение  рекламы.  Для  желающих  продемонстрировать  свои
 аппаратные и/или программные продукты  предусмотрены  выставочные
 площади с необходимым оборудованием.

 Семинар  будет  проводиться  в  Международном   центре  научной и
 технической  информации (Москва, ул. Куусинена, дом 21б).  Проезд
 от ст. метро "Полежаевская" на троллейбусе 43 или 65 до остановки
 МЦНТИ. Предполагаемое количество участников -200 человек из стран
 СНГ и 35 человек иностранных участников.  Регистрационный   взнос
 - рублевый эквивалент 7$ США на момент перевода денег, для членов
 SUUG - 6$ США с человека.  В  регистрационный  взнос  входят  все
 организационные расходы, включая выпуск сборника тезисов докладов
 конференции. При оплате Вашего участия  НЕ  ЗАБУДЬТЕ   указать на
 платежном поручении код SUUG-93 и фамилию участника, за  которого
 оплачивается взнос!

 Иногородним заказывается   гостиница   (стоимость   проживания  в
 гостинице не включена в регистрационный взнос).
 Заезд и регистрация участников - 20 апреля. 21 - 24 апреля работа
 семинара.  Для  участия  в   семинаре   необходимо   выслать   по
 адресу/факсу организационного комитета копию платежного поручения
 и  заявку  на  участие  по  прилагаемому  образцу.  Заявки  можно
 присылать электронной почтой.  В связи с ограниченным числом мест
 (200  мест  для  участников  из  стран  СНГ)  приоритетом   будут
 пользоваться  члены  SUUG  и  авторы  докладов  (далее  приоритет
 определяется порядком поступления заявок).

 Желающие  выступить  с  докладом  должны  также  выслать в  адрес
 оргкомитета до 15 февраля тезисы докладов (не более  4  стр.)  на
 русском   или   английском  языке.   Тезисы  желательно  оформить
 следующим образом: название доклада, фамилии авторов с инициалами,
 название  организации, E-mail или адрес организации  (расположить
 "по центру"  в порядке, указанном выше).
 Оповещение программного   комитета   о  принятии  или  отклонении
 доклада будет разослано авторам до 15 марта.
 Печать будет    производиться   с   присланного   оригинала   без
 редакторской  вычитки.  Доклады  принимаются  в   пригодном   для
 воспроизведения виде (четкая печать),  или по электронной почте в
 форматах ASCII, MS WORD.

 ОРГАНИЗАЦИОННЫЙ КОМИТЕТ

 Секретарь - Е.Е.Алферова
 МЦНТИ, Москва, ул. Куусинена, дом 21б.
 Советская ассоциация пользователей ОС UNIX (SUUG)
 Тел: (095) 198-98-63
 Факс:(095) 943-00-89
 E-mail: <elena@plb.icsti.su>

 ПРОГРАММНЫЙ КОМИТЕТ

 Председатель - С.Д.Кузнецов
 Тел.: (095) 272-44-25
 Факс: (095) 125-43-80
 E-mail: <kuz@ivann.delta.msk.su>

 Ученый секретарь - П.Л.Брусиловский
 Тел: (095) 198-70-55
 E-mail: <plb@plb.icsti.su>


                                 * * *

******** CNN ПРЕДЛАГАЕТ БЕСПЛАТНЫЕ ИНФОРМАЦИОННЫЕ УСЛУГИ **********
****** (FREE  OF  CHARGE  USA-BASED  INFORMATION  SERVICE) ********

 To: subscribers
 From: Alexandr Draganov <draganov@nova.stanford.edu>
 Newsgroups: relcom.netnews,relcom.talk,relcom.commerce
 Subject: [News] **FREE INFORMATION SERVICE**
 Date: Sun, 27 Dec 92 18:06:48 -0800
 Distribution: su
 Organization: unknown
 Message-ID: <CMM.0.90.4.725508408.draganov@nova1.stanford.edu>
 Reply-To: draganov@nova.stanford.edu
 Sender: L-relcom@newcom.kiae.su
 Status: R

     ************************************************************
          FREE  OF  CHARGE  USA-BASED  INFORMATION  SERVICE
     ************************************************************


   THIS MESSAGE IS TO OFFER FREE INFORMATION SERVICE TO EVERYBODY WHO IS
  INTERESTED. IT WORKS IN A SIMPLE WAY: YOU ASK, AND IN FEW DAYS YOU GET THE
   ANSWER. THERE IS NO OBLIGATIONS FROM YOUR SIDE AND NO CHARGES FOR YOU.


 A nonprofit organization called Christian Neighbors' Network (CNN), is
 ready to provide valuable pieces of advice and information from its members.
 This an experimental project so far, and we are making this exceptional
 offer to get a better idea of needs in the field of information exchange.
 This offer is valid to those living in the countries of the former Soviet
 Union only.

 *************WHAT KIND OF QUESTIONS MAY BE ASKED ?***************

 Actually, any your question which deals with business, life, science in
 the USA.  Here are few examples:

 - You would like to suggest something, and we find addresses of
  people/companies who might be interested.  This might be also helpful
  for researchers who wish to establish professional contacts with their
  colleagues, etc.

 - You are interested in making business with the USA (or other countries),
  and you wish to know how your field of business is regulated by law, what
  is commercial profile of different companies in the your field of interest,
  etc.

 - You want to know the average price of a product in the USA, or any other
  everyday information.

 - Virtually any other question.


 *******************WHO  ANSWERS  YOUR  QUESTIONS ?*******************

 Even the most sophisticated questions may be answered by experts from
 Christian Neighbors' Network (CNN).  Located in the Silicon Valley, CNN
 embraces top managers of some of American high-tech companies. There are
 also investment managers, owners of local businesses, and members of
 local municipal governments in CNN organisation. There are also regular
 people, who are living and working in California. In many cases, we can
 use online computer databases all over the world to find information on
 your request. Huge information resources of Stanford University can be
 used as well.


 **********************WHAT  DO  YOU  GET ?**************************

 We will do our best to answer ANY your question in few days, in the most
 complete and precise way.  You will get the requested information to your
 electronic or regular mail address absolutely free of charge.  Of course,
 you understand, that there might be cases when we are unable to find the
 answer to your question.  However, you do not risk anything by asking, so
 why you would not try ?

 I would like to urge you to use this unique opportunity.


 Very truly yours,
 Alexandr Draganov,

 e-mail:  draganov@nova.stanford.edu

 mail:  A. Draganov
        324 Durand
        STAR Laboratory
        Stanford University
        Stanford, CA 94305

                                 * * *

************** МИКРОСОФТ ОТКРЫВАЕТ ФИЛИАЛ В МОСКВЕ *********************

 MOSCOW, RUSSIA, 1992 DEC 15 (NB) -- After months of speculation,
 Microsoft has announced it has registered its first wholly owned
 subsidiary, Microsoft A/O, in Russia. The new company has a
 registered capital of $5,000.

 To date, most of Microsoft's products have been sold in Russia through
 third-party companies. That situation may change, as it has done in
 other East European countries where Microsoft has got a foot in the
 distribution door. Microsoft officials have said that the company
 plans to invest several million dollars in the Russian operation.

 Industry observers, however, suggest that it could take some time
 before the software giant generates actual profits from its Russian
 operations.

 Microsoft A/O is headquartered at 14 Staraja Basmannaja St, Moscow and
 will be headed by Robert Clough, a Californian University graduate who
 was formerly a business development manager with Nantucket's
 operations in Moscow.

 Plans call for the new company to service the needs of all the
 republics within the former Soviet Union, including the Asian and
 Baltic republics.

 Announcing the formation of the new company, Bernard Vergnes,
 Microsoft Europe's president, said that there are no plans -- for the
 time being at least -- to open any further subsidiaries in Central
 Europe. This would appear to exclude the company's Romanian operation,
 which opens for business after Christmas.

 Vergnes was speaking at a two-day presentation at the
 Balchug-Kempinsky hotel, a plush site in downtown Moscow. According to
 Jurgen Stranghoener, Microsoft Eastern Europe's director, the
 relatively low capitalization of the new company does not suggest that
 Microsoft will not put money into the operation. Plans call, he said,
 for the software giant to continue to invest in the Russian
 market-place and for it to support the development of the software
 industry in the country for the coming years.

 Clough, Microsoft A/O's managing director, said that the new company
 officially came into being on December 1, when it was first
 registered. Plans call for business to start in early January, with
 Microsoft taking on another nine staff early in the New Year,
 complementing the two (including Clough) already on the payroll.

 Clough is wasting no time when it comes to getting the show on the
 road. A new price list for the company's complete range of products
 has been issued and distributor orders will be accepted for delivery
 from the beginning of January. Among the many products on the
 company's price list are international versions of Windows, DOS, and
 Works for DOS.

 The new prices could spell the end for many profitable software import
 operations in Russia. Pricing has been set in rubles, which
 could cause a long-term headache for Microsoft in that cheap Russian-
 sourced versions of its software could -- in theory at least -- be
 exported to other Central European countries. Microsoft claims it can
 handle the potential problem.

 Microsoft is working on a number of local language editions of its
 software, including Windows 3.1, Word for Windows, Works for Windows
 and Excel for Windows.

 The news contradicts previous reports that a Russian version for
 Windows 3.1 would be available in November, 1992. Some Microsoft
 sources had suggested that a swathe of Russian language editions of
 Microsoft software would ship in the first quarter of 1993 -- that
 suggestion now looks to have been over-optimistic.

 Microsoft officials said they are also speaking with Apple about the
 localization of Microsoft Excel for the Mac. This comes as something
 of a surprise as some sources have indicated that there are barely
 2,000 Macs in active use here in Russia.

 Microsoft is wasting no time when it comes to new country operations.
 Last month saw new subsidiaries open in Czechoslovakia, Hungary and
 Poland. Plans are in hand for a new company to begin operations in
 Bucharest, Romania in January.

 (Kirill Tchashchin/19921215/Press Contact: Microsoft Moscow, Dmitry
 Kartsev, phone +7 095 262-12-13; fax +7 095 262-2351; Paul Robson,
 Microsoft Germany, phone +49 89 3167-3831 )
                                        Перепечатано из Clarinet News

                                 * * *


************** МИКРОСОФТ ОБВИНЕН В НЕЧЕСТНОЙ КОНКУРЕЦИИ ***************

 REDMOND, WASHINGTON, U.S.A., 1992 DEC 18 (NB) -- Business Week
 magazine, in its December 28th issue, says FTC investigators have
 concluded that the software company has engaged in anticompetitive
 actions. The magazine also reports that the investigators are
 preparing recommendations as to how to proceed against the company.

 According to Business Week, the recommendations being prepared by
 the agency's investigators could include breaking up the company,
 altering the way its software is sold to computer makers, or
 isolating the divisions from each other. The latter move, if
 adopted, would effectively have each division operating as a
 separate entity.

 Business Week says the investigators focused on Microsoft's
 "aggressive tactics" including the way it licenses its software to
 computer makers. The company reportedly has 95 percent of the
 operating systems market for personal computers powered by Intel
 microprocessors. The magazine also claims that the report alleges
 that Microsoft has unfairly used its dominance to gain an edge in
 development of such software applications as word processing
 programs and spreadsheets.

 Rival software companies have complained publicly and apparently to
 the Federal Trade Commission that Microsoft uses "predatory
 practices" in selling its operating systems. The operating system is
 the software which provides basic functions such as file management,
 and is the foundation from which applications such as word
 processing programs run. Allegations have also been made that
 Microsoft dumped software at prices designed to drive other
 companies from the market.

 When contacted by Newsbytes late Thursday, a Microsoft spokesperson
 would only say "No comment."

 (Jim Mallory/19921218/Press contact: Christine Summerson, Business
 Week, 212-512-2882)
                                 * * *

************* NOVELL ПОКУПАЕТ USL (Unix System Laboratories) *************


 >From newsbytes@clarinet.com Tue Dec 22 18:32:38 1992
 Path: farmua!relay1!csoft!kiae!demos!fuug!mcsun!uunet!looking!newsbytes
 From: newsbytes@clarinet.com
 Newsgroups: clari.nb.unix,clari.nb.top,biz.clarinet.sample
 Subject:  ****Novell to Acquire Unix System Laboratories 12/21/92
 Keywords: Bureau-TOR
 Date: 21 Dec 92 20:54:07 GMT
 Message-ID: <NB921221.21@clarinet.com>
 Approved: cn@clarinet.com
 Lines: 79

 SUMMIT, NEW JERSEY, U.S.A., 1992 DEC 21 (NB) -- Networking vendor
 Novell, Inc., of Provo, Utah, has signed a letter of intent to
 acquire Unix System Laboratories from AT&T. If completed, the deal
 will make Novell a significant force in computer operating systems
 on several fronts and make AT&T, which developed Unix in the 1970s,
 just another in the pack of hardware vendors that sell Unix.

 Novell's NetWare is the top-selling operating system for personal
 computer local-area networks (LANs). Also, the company controls
 Digital Research Inc., the maker of DR-DOS, a system compatible
 with the market-leading MS-DOS PC operating system from Microsoft.

 USL is a subsidiary of AT&T that provides computer vendors with
 the Unix operating system and related software and services based
 on open, international standards for computing and communications.

 AT&T spun off its Unix operation in 1991 to create Unix System
 Laboratories. Shortly afterward, the company sold a portion of
 the company to a number of other computer companies, saying the
 growth of Unix required that the operation have more independence.

 AT&T spokesman Dick Gray said the sale of the entire operation to
 Novell would help USL concentrate on the further development of
 Unix and selling the software to all vendors.

 AT&T now owns about 77 percent of USL. Novell already owns five
 percent of the company, and the rest belongs to a variety of
 other shareholders, including Motorola Inc., Sun Microsystems
 Inc., and others. USL's annual revenues are more than $80
 million, officials said.

 Under the terms of the letter of intent, existing shares of USL
 common stock would be exchanged for up to 12.3 million newly
 issued shares of Novell common stock in a tax-free merger
 accounted for as a purchase.

 Novell would issue about 11.1 million shares of common stock to
 the current non-Novell USL shareholders. Outstanding USL stock
 options and other equity incentives would be exchanged for Novell
 stock, or options, or rights to acquire shares of Novell stock,
 all in accordance with the terms of USL employee plans and the
 definitive agreement.

 USL will become a wholly owned subsidiary of Novell, maintaining
 its operations in Summit.

 AT&T will continue to be a major vendor of Unix systems through
 its NCR unit, Gray said, and will continue doing some Unix
 research and development of its own.

 AT&T expects to realize a gain of about $100 million in net
 income on the deal based on the current price of Novell stock,
 and will come out of the deal owning about three percent of
 Novell, officials said.

 The deal has been approved by the boards of directors of Novell
 and AT&T, but still needs the approval of USL stockholders and
 regulators, the signing of a definitive merger agreement and
 other normal conditions. Officials said they hope to close the
 deal in the first quarter of 1993.

 Stan Schatt, analyst with Infocorp, told Newsbytes that, "What's
 clear is that Novell is very serious about Unix, as a direct
 competitor and desktop to Windows NT. Windows NT is really
 just vaporware right now. So there is a 'window-of-opportunity'
 for Novell at this point."

 In reply to a question concerning how much Unix will gain from
 the deal, Schatt said, "Unix sales will go up. There is some doubt
 on the part of some Unix people whether Novell intends to fully
 support all the Unix open standards. But today in the news
 conference, Novell affirmed the fact that it would, so I think
 that should satisfy most of them."

 (Grant Buckler & Ian Stokell/19921221/Press Contact: Peter Troop, Novell,
 408-473-8361; Dick Gray, AT&T, 908-221-5057; Larry Lytle, USL,
 908-522-5186)
                                 * * *

********************* КАК HА ЗАПАДЕ ОТHОСЯТСЯ К ПИРАТАМ **********************

 =============================================================================
 * Forwarded by Andrew Kovalev (2:5020/23.50) using GoldED 2.40.P0720+
 * Area : ENET.SYSOP (ENET.SYSOP)
 * From : Tirs Abril, 2:343/106 (31 Дек 1992 (Чт) 23:51)
 * To   : Ron Dwight
 * Subj : Cracked FD 2.10
 =============================================================================

 Hey JoHo! Might I use some cracked FD 2.10 for my own private network? Since I
 won't use'em in FidoNet, there should be no problem, ok?

 Hey Tobias! I'm planning to build a pirate, totally private network. No problem
 on using cracked FastEchos, huh?

 Hey Folkert! I *absolutely need* the retear option in your FMail program, but I
 don't want to afford the 1500pta (four beers) it costs in Spanish currency! No
 problem, in cracking, then?

 And so ad libitum, ad infinitum, ad nauseam. As some of the aforementioned nice
 guys know, I've been working against piracy in FidoNet in various fronts. Will
 it be only to see how they simply say "out of Fidonet, everything is valid" and
 continue using their dirty, rotten-smelling software freely in our network and
 even announcing and promotioning it?

 Please Ron, DON'T ALLOW THESE GUYS TO CHEAT YOU! They are making profit on
 others' work; they are CRIMINALS. Efraim is trying to get rid of them long time
 ago, but they know how to tell lies to a person who lives in Finland, not in
 Region 34, and therefore is not able to see what are they doing with his own
 eyes. Please, think of it (I know, you have lots of things to think of) and let
 Efraim keep Fidonet clean of pirates.

 ______
  | !rs
 ___
  + Origin: Zone 2 is Copydwight (c) Fido, 1993 (2:343/106)



************* Стоимость акций APPLE превысила стоимость акций IBM ****************

 To: netters
 Sender: L-usenet@river.cs.kiev.ua
 From: newsbytes@clarinet.com
 Newsgroups: clari.nb.business,clari.nb.top,biz.clarinet.sample
 Subject: [NEWS] ****For 1st Time, Apple's Stock Higher Than IBM's 12/17/92
 Keywords: Bureau-LAX
 Date: 17 Dec 92 20:54:30 GMT
 Message-ID: <NB921217.7@clarinet.com>
 Approved: cn@clarinet.com
 Lines: 33

 CUPERTINO, CALIFORNIA, U.S.A., 1992 DEC 17 (NB) -- Apple
 Computer's stock is selling for more than IBM for the first
 time ever.

 Apple Computer's shares were selling at $55.75 on December 16,
 while Merrill Lynch representatives told Newsbytes IBM's stock
 the same day was at $52.25. This is the first time in the
 existence of the two companies that Apple's stock has sold for
 more per share than IBM stock, according to Eric Clow of
 Computer Intelligence. However, the number of outstanding
 shares of stock as well as the price determines the market
 value of a company.

 Prudential Securities analysts told Newsbytes Apple has $118
 million shares at $55.75 per share, while IBM has 571 million
 shares at $52.25 per share.

 While both companies have announced layoffs and restructuring
 plans, IBM has been facing red ink and has for the first time
 been talking about cutting its dividend to stockholders.

 Dan Ness of Computer Intelligence told Newsbytes, "The
 dividend is what blue chip stocks are all about. You get those
 stocks and cut those dividend coupons."

 IBM's stock is at its lowest point in several years. Prudential
 Securities representatives told Newsbytes the company's stock
 five years ago was in the $140 per share range.

 (Linda Rohrbough/19921217/Press Contact: Prudential Securities,
 415-981-0440; Dan Ness, Computer Intelligence, 619-535-6733;
 Merrill Lynch 818-990-7788)


