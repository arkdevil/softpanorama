>From news-service Tue Dec 15 01:03:44 1992
To: subscribers
Newsgroups: comp.compression,comp.compression.research,sci.astro,sci.space
From: beser@netnews.jhuapl.edu (Nick Beser)
Subject: [News] Space Based Data Compression Standard
Message-ID: <Bz082L.5Fn@netnews.jhuapl.edu>
Summary: Call for Participation in Standard Development
Keywords: Data Compression, Standards
Organization: JHU/Applied Physics Laboratory
Date: Wed, 09 Dec 92 18:15:56 GMT
Sender: L-usenet@newcom.kiae.su
Status: RO


        New Standard Development - Call for Participation

             Standard for Space Based Data Compression

At the November 6, 1991  AIAA Standards Technical Council meeting a
three part project to develop a Space Based Data Compression Standard
was approved. This is a multi-year effort and will result in a Data
Compression Guide, an Evaluation Criteria/Reference Data Set and a draft
standard for space based data compression.

Why Data Compression?

Space Based Observations require the transmission of a variety of different
types of data through the spacecraft communications system to the ground.
The data must be sent though a communications system that is limited in
bandwidth and is being shared among sensors. Greater utilization of the
limited resources of an observation system can be accommodated by the use
of data compression. There is a perception that data compression is an
experimental technique and this is supported by the absence of ANSI or
ISO standards that guide the design and implementation of space based data
compression. Data compression has been used on board satellites since the
mid 1960's. The lack of standards coupled with the lack of historical
record and need to use data compression on future missions makes this
project both timely and urgent.

Call for Help:

The success of this project is dependent on recruiting an active committee
that will pull together the different disciplines that make up the data
compression problem. To complete this project we will be writing a data
compression recommended practices guide that will include background
theory, descriptions of techniques, case studies and other implementation
considerations. Data compression evaluation criteria and reference data
will also be developed that will include sensor and mission requirements as
well as system design information. We will be developing a method of
comparing and rating the performance of different data compression
methods, and identifying test data that is representative of space based
collected data. The test data and evaluation software will be published as a
CD-ROM so that projects and companies that want to evaluate their
compression methods can have a common framework for performance
measures. We currently have outlines of the recommended practices guide,
code for compression metrics, test images, and some draft material.
Depending on the outcome of the first two activities a data compression
standard will be either endorsed or developed.

We are looking for researchers and engineers who are engaged in the
development, evaluation and selection of data compression methods for
space applications. We are also looking for Sensor and Experiment Design
Experts and Systems Engineers to help write sections of the Guide
including case studies of past, current and future missions. If you have an
interest in the application of data compression to space based data or know
of someone at your company who is currently working the problem, please
join us at the next SBOS/COS or join our e-mail list. Our next two
meetings will be held in the Baltimore-Washington area.

We have established an Electronic Mail List to help keep the committee in
contact during this project. If you have DOD Internet access or internet
mail, our address to join the mailing list is:

        space-comp-std-request@aplcomm.jhuapl.edu

The address to send messages to the committee is:

        space-comp-std@aplcomm.jhuapl.edu

All messages sent to the space-comp-std address will be repeated to
everyone on the mailing list. Send your internet mail address to the space-
comp-std-request@aplcomm.jhuapl.edu address to join. Using this forum,
we can keep everyone informed of progress, and get comments on drafts
on a daily (in some cases minute) basis. We also have an archive site
located at aplcomm.jhuapl.edu that is reachable using internet ftp (File
Transfer Protocol). We plan to use the archive site to store drafts,
evaluation software and small reference data sets.

Dr. Nicholas Beser (APL)                        Dr. Thomas Lynch (Hughes)
(301) 953-5000 ext 4476                                 (703) 759-1331

>From news-service Tue Dec 15 01:03:44 1992
To: subscribers
Newsgroups: comp.compression.research
From: jbek@oce.nl (Hank van Bekkem)
Subject: [News] Introduction to JBIG.
Message-ID: <1992Dec9.083648.13484@oce.nl>
Organization: OCE Nederland B.V.
Date: Wed, 09 Dec 92 08:36:48 GMT
Sender: L-usenet@newcom.kiae.su
Status: RO

To raise the level of interest in JBIG, I thought a short introduction
would be helpful.

Hank van Bekkem
Groups Research Department III
Oce Nederland B.V.


Note:
the following description of the JBIG algorithm is derived from
experiences with a software implementation I wrote following the
specifications in the revision 4.1 draft of September 16, 1991. The
source will not be made available in the public domain, as parts of
JBIG are patented.

JBIG (Joint Bi-level Image Experts Group) is an experts group of ISO,
IEC and CCITT (JTC1/SC2/WG9 and SGVIII). Its job is to define a
compression standard for lossless image coding ([1]). The main
characteristics of the proposed algorithm are:
- Compatible progressive/sequential coding. This means that a
  progressively coded image can be decoded sequentially, and the
  other way around.
- JBIG will be a lossless image compression standard: all bits in
  your images before and after compression and decompression will be
  exactly the same.

In the rest of this text I will first describe the JBIG algorithm in
a short abstract of the draft. I will conclude by saying something
about the value of JBIG.


JBIG algorithm.
--------------

JBIG parameter P specifies the number of bits per pixel in the image.
Its allowable range is 1 through 255, but starting at P=8 or so,
compression will be more efficient using other algorithms. On the
other hand, medical images such as chest X-rays are often stored with
12 bits per pixel, while no distorsion is allowed, so JBIG can
certainly be of use in this area. To limit the number of bit changes
between adjacent decimal values (e.g. 127 and 128), it is wise to use
Gray coding before compressing multi-level images with JBIG. JBIG
then compresses the image on a bitplane basis, so the rest of this
text assumes bi-level pixels.

Progressive coding is a way to send an image gradually to a receiver
instead of all at once. During sending, more detail is sent, and the
receiver can build the image from low to high detail. JBIG uses
discrete steps of detail by successively doubling the resolution. The
sender computes a number of resolution layers D, and transmits these
starting at the lowest resolution Dl. Resolution reduction uses
pixels in the high resolution layer and some already computed low
resolution pixels as an index into a lookup table. The contents of
this table can be specified by the user.

Compatibility between progressive and sequential coding is achieved
by dividing an image into stripes. Each stripe is a horizontal bar
with a user definable height. Each stripe is separately coded and
transmitted, and the user can define in which order stripes,
resolutions and bitplanes (if P>1) are intermixed in the coded data.
A progressive coded image can be decoded sequentially by decoding
each stripe, beginning by the one at the top of the image, to its
full resolution, and then proceeding to the next stripe. Progressive
decoding can be done by decoding only a specific resolution layer
from all stripes.

After dividing an image into bitplanes, resolution layers and
stripes, eventually a number of small bi-level bitmaps are left to
compress. Compression is done using a Q-coder. Reference [2]
contains a full description, I will only outline the basic principles
here.

The Q-coder codes bi-level pixels as symbols using the probability of
occurrence of these symbols in a certain context. JBIG defines two
kinds of context, one for the lowest resolution layer (the base
layer), and one for all other layers (differential layers).
Differential layer contexts contain pixels in the layer to be coded,
and in the corresponding lower resolution layer.

For each combination of pixel values in a context, the probability
distribution of black and white pixels can be different. In an all
white context, the probability of coding a white pixel will be much
greater than that of coding a black pixel. The Q-coder assigns, just
like a Huffman coder, more bits to less probable symbols, and so
achieves compression. The Q-coder can, unlike a Huffmann coder,
assign one output codebit to more than one input symbol, and thus is
able to compress bi-level pixels without explicit clustering, as
would be necessary using a Huffman coder.

Maximum compression will be achieved when all probabilities (one set
for each combination of pixel values in the context) follow the
probabilities of the pixels. The Q-coder therefore continuously
adapts these probabilities to the symbols it sees.


JBIG value.
----------

In my opinion, JBIG can be regarded as two combined devices:
- Providing the user the service of sending or storing multiple
  representations of images at different resolutions without any
  extra cost in storage. Differential layer contexts contain pixels
  in two resolution layers, and so enable the Q-coder to effectively
  code the difference in information between the two layers, instead
  of the information contained in every layer. This means that,
  within a margin of approximately 5%, the number of resolution
  layers doesn't effect the compression ratio.
- Providing the user a very efficient compression algorithm, mainly
  for use with bi-level images. Compared to CCITT Group 4, JBIG is
  approximately 10% to 50% better on text and line art, and even
  better on halftones. JBIG is however, just like Group 4, somewhat
  sensitive to noise in images. This means that the compression ratio
  decreases when the amount of noise in your images increases.

An example of an application would be browsing through an image
database, e.g. an EDMS (engineering document management system).
Large A0 size drawings at 300 dpi or so would be stored using five
resolution layers. The lowest resolution layer would fit on a
computer screen. Base layer compressed data would be stored at the
beginning of the compressed file, thus making browsing through large
numbers of compressed drawings possible by reading and decompressing
just the first small part of all files. When the user stops browsing,
the system could automatically start decompressing all remaining
detail for printing at high resolution.

[1] "Progressive Bi-level Image Compression, Revision 4.1", ISO/IEC
    JTC1/SC2/WG9, CD 11544, September 16, 1991
[2] "An overview of the basic principles of the Q-coder adaptive
    binary arithmetic coder", W.B. Pennebaker, J.L. Mitchell, G.G.
    Langdon, R.B. Arps, IBM Journal of research and development,
    Vol.32, No.6, November 1988, pp. 771-726 (See also the other
    articles about the Q-coder in this issue)

      ###########################################################
      #  This note does not necessarily represent the position  #
      #     of Oce-Nederland B.V. Therefore no liability or     #
      #      responsibility for whatever will be accepted.      #
      ###########################################################

С уважением


--
Sergey Molyavko: postmast@bhv.kiev.ua   (Relcom) | voice (044)-269-0423
 postmast%bhv.kiev.ua@relay.ussr.eu.net (Internet) | fax (044)-228-7272 BHV
Trading & Publishing Bureau BHV Ltd., Kiev, Ukraine  <<Computer Books>>


