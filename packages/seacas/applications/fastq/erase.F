C    Copyright(C) 2014-2017 National Technology & Engineering Solutions of
C    Sandia, LLC (NTESS).  Under the terms of Contract DE-NA0003525 with
C    NTESS, the U.S. Government retains certain rights in this software.
C
C    Redistribution and use in source and binary forms, with or without
C    modification, are permitted provided that the following conditions are
C    met:
C
C    * Redistributions of source code must retain the above copyright
C       notice, this list of conditions and the following disclaimer.
C
C    * Redistributions in binary form must reproduce the above
C      copyright notice, this list of conditions and the following
C      disclaimer in the documentation and/or other materials provided
C      with the distribution.
C
C    * Neither the name of NTESS nor the names of its
C      contributors may be used to endorse or promote products derived
C      from this software without specific prior written permission.
C
C    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
C    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
C    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
C    A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
C    OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
C    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
C    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
C    DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
C    THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
C    (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
C    OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
C

C $Id: erase.F,v 1.1 1998/04/10 04:30:12 gdsjaar Exp $
C $Log: erase.F,v $
C Revision 1.1  1998/04/10 04:30:12  gdsjaar
C Added the ifdef needsdoubleescape to the graphics symbol
C plotting. Required moving some .f to .F files and specifying in Imakefile
C
C Revision 1.1.1.1  1990/11/30 11:06:44  gdsjaar
C FASTQ Version 2.0X
C
c Revision 1.1  90/11/30  11:06:42  gdsjaar
c Initial revision
c
C
CC* FILE: [.MAIN]ERASE.FOR
CC* MODIFIED BY: TED BLACKER
CC* MODIFICATION DATE: 7/6/90
CC* MODIFICATION: COMPLETED HEADER INFORMATION
C
      SUBROUTINE ERASE (MP, ML, MS, MR, N, COOR, ILINE, LTYPE, LCON,
     &   NLPS, IFLINE, ILLIST, NSPR, IFSIDE, ISLIST, LINKP, LINKL,
     &   LINKS, LINKR, IBAD, ALPHA)
C***********************************************************************
C
C  SUBROUTINE ERASE = ERASES A POINT,  AND ALL DATA DEPENDANT ON THAT
C                     POINT  (I.E. LINES,  SIDES,  OR REGIONS)
C
C***********************************************************************
C
      DIMENSION COOR (2, MP), ILINE (ML), LTYPE (ML), LCON (3, ML)
      DIMENSION NLPS (MS)
      DIMENSION IFLINE (MS), ILLIST (MS * 3), NSPR (MR), IFSIDE (MR)
      DIMENSION ISLIST (MR * 4)
      DIMENSION LINKP (2, MP), LINKL (2, ML), LINKS (2, MS)
      DIMENSION LINKR (2, MR)
      DIMENSION N (29)
C
      LOGICAL NUMPLT, ALPHA, ADDLNK, TEST, GETMAX
C
      IZ = 0
      KNUM = 0
      ADDLNK = .FALSE.
      TEST = .FALSE.
      GETMAX = .FALSE.
C
C  ERASE ANY REGIONS USING THAT POINT
C
      DO 140 I = 1, N (22)
         CALL LTSORT (MR, LINKR, I, II, ADDLNK)
         IF (II .GT. 0) THEN
            DO 130 J = IFSIDE (II), IFSIDE (II) + NSPR (II) - 1
               CALL LTSORT (MS, LINKS, ISLIST (J), IPNTR, ADDLNK)
               IF ( (ISLIST (J) .GT. 0) .AND. (IPNTR .GT. 0)) THEN
                  JJ = ISLIST (J)
                  DO 110 K = IFLINE (JJ), IFLINE (JJ) + NLPS (JJ) - 1
                     CALL LTSORT (ML, LINKL, ILLIST (K), KK, ADDLNK)
                     IF (KK .GT. 0) THEN
                        DO 100 L = 1, 2
                           IF (IBAD .EQ. LCON (L, KK)) THEN
                              ADDLNK = .TRUE.
                              CALL LTSORT (MR, LINKR, I, IZ, ADDLNK)
                              ADDLNK = .FALSE.
                           ENDIF
  100                   CONTINUE
                        IF (IBAD .EQ. LCON (3, KK)) THEN
                           ADDLNK = .TRUE.
                           CALL LTSORT (MR, LINKR, I, IZ, ADDLNK)
                           ADDLNK = .FALSE.
                        ENDIF
                     ENDIF
  110             CONTINUE
               ELSEIF (ISLIST (J) .LT. 0) THEN
                  JJ = IABS (ISLIST (J))
                  CALL LTSORT (ML, LINKL, JJ, KK, ADDLNK)
                  IF (KK .GT. 0) THEN
                     DO 120 L = 1, 2
                        IF (IBAD .EQ. LCON (L, KK)) THEN
                           ADDLNK = .TRUE.
                           CALL LTSORT (MR, LINKR, I, IZ, ADDLNK)
                           ADDLNK = .FALSE.
                        ENDIF
  120                CONTINUE
                     IF (IBAD .EQ. LCON (3, KK)) THEN
                        ADDLNK = .TRUE.
                        CALL LTSORT (MR, LINKR, I, IZ, ADDLNK)
                        ADDLNK = .FALSE.
                     ENDIF
                  ENDIF
               ENDIF
  130       CONTINUE
            CALL LTSORT (MR, LINKR, I, IPNTR, ADDLNK)
            IF ( (.NOT.ALPHA) .AND. (IPNTR .LE. 0)) THEN
               CALL REGEXT  (MP,  ML,  MS,  MR,  N,  II,  COOR, ILINE,
     &            LTYPE,  LCON,  NLPS,  IFLINE,  ILLIST,  NSPR, IFSIDE,
     &            ISLIST,  LINKP,  LINKL,  LINKS,  LINKR,  XMIN, XMAX,
     &            YMIN,  YMAX)
               XMID =  (XMAX + XMIN) / 2.
               YMID =  (YMAX + YMIN) / 2.
#if NeedsDoubleEscape
               CALL MPD2SY (1, XMID, YMID, '\\CDI')
#else
               CALL MPD2SY (1, XMID, YMID, '\CDI')
#endif
               CALL PLTFLU
            ENDIF
         ENDIF
  140 CONTINUE
C
C  ERASE ANY SIDES USING THAT POINT
C
      DO 180 I = 1, N (20)
         CALL LTSORT (MS, LINKS, I, II, ADDLNK)
         IF (II .GT. 0) THEN
            DO 160 J = IFLINE (II), NLPS (II) + IFLINE (II) - 1
               CALL LTSORT (ML, LINKL, ILLIST (J), JJ, ADDLNK)
               DO 150 K = 1, 3
                  IF (IBAD .EQ. LCON (K, JJ)) THEN
                     ADDLNK = .TRUE.
                     CALL LTSORT (MS, LINKS, I, IZ, ADDLNK)
                     ADDLNK = .FALSE.
                     GOTO 170
                  ENDIF
  150          CONTINUE
  160       CONTINUE
  170       CONTINUE
         ENDIF
  180 CONTINUE
C
C  ERASE ANY LINES USING THAT POINT
C
      DO 210 I = 1, N (19)
         CALL LTSORT (ML, LINKL, I, II, ADDLNK)
         IF (II .GT. 0) THEN
            DO 190 J = 1, 3
               IF (IBAD .EQ. LCON (J, II)) THEN
                  LT = LTYPE (II)
                  IP1 = LCON (1, II)
                  IP2 = LCON (2, II)
                  IP3 = LCON (3, II)
                  CALL LTSORT (MP, LINKP, IP1, IPNTR1, ADDLNK)
                  CALL LTSORT (MP, LINKP, IP2, IPNTR2, ADDLNK)
                  IF (IP3 .NE. 0) THEN
                     CALL LTSORT (MP, LINKP, IABS (IP3), IPNTR3, ADDLNK)
                  ELSE
                     IPNTR3 = 0
                  ENDIF
                  IF ( (IPNTR1 .GT. 0) .AND. (IPNTR2 .GT. 0) .AND.
     &               ( (LT .EQ. 1) .OR. (IPNTR3 .GT. 0))) THEN
                     IF (.NOT.ALPHA) THEN
                        CALL DLINE (MP, ML, COOR, LINKP, KNUM, LT, IP1,
     &                     IP2, IP3, NUMPLT, DUM1, DUM2, TEST, GETMAX,
     &                     DUM3, DUM4, DUM5, DUM6)
                        CALL PLTFLU
                     ENDIF
                  ENDIF
                  ADDLNK = .TRUE.
                  CALL LTSORT (ML, LINKL, I, IZ, ADDLNK)
                  ADDLNK = .FALSE.
                  GOTO 200
               ENDIF
  190       CONTINUE
  200       CONTINUE
         ENDIF
  210 CONTINUE
C
C  DELETE THE POINT
C
      ADDLNK = .FALSE.
      CALL LTSORT (MP, LINKP, IBAD, II, ADDLNK)
      ADDLNK = .TRUE.
      CALL LTSORT (MP, LINKP, IBAD, IZ, ADDLNK)
      IF (.NOT.ALPHA) THEN
#if NeedsDoubleEscape
         CALL MPD2SY (1, COOR (1, II), COOR (2, II), '\\CX')
#else
         CALL MPD2SY (1, COOR (1, II), COOR (2, II), '\CX')
#endif
         CALL PLTFLU
      ENDIF
C
      RETURN
C
      END
