/*
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 * Authors: Dahmun Goudarzi, Anthony Journault, Matthieu Rivain and François-
 * Xavier Standaert
 *
 */



    AREA    pini1_code, CODE, READONLY



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                                                                           ;;
;;                        PINI1 MULTIPLICATION FUNCTION                      ;;
;;                                                                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


pini1_mult

    ;; ------------------------------------------------------------------------
    ;; init phase

    LDR     R7, =RNGTab

    ;; ------------------------------------------------------------------------
    ;;  c_i = a_i AND b_i

    MOV     R12, #0
loop0pini1
    LDR     R4, [R0,R12, LSL #2]
    LDR     R5, [R1,R12, LSL #2]
    AND     R6, R4, R5
    STR     R6, [R2,R12, LSL #2]
    ;; loop 0 processing
    ADD     R12, #1
    CMP     R12, #MASKING_ORDER
    BNE     loop0pini1

    ;; ------------------------------------------------------------------------
    ;; s_ij = b_j + r_ij
    ;; p1_ij = a_i * s_ij
    ;; p0_ij = not(a_i) * r_ij
    ;; c_i += p0_ij + p1_ij

    ;; s_ji = b_i + r_ij
    ;; p0_ji = not(a_j) * r_ij
    ;; p1_ij = a_j * s_ji
    ;; c_j += p0_ji + p1_ji

    MOV     R12, #0
loop1pini1
    ADD     R11, R12, #1
loop2pini1
    ;; r <-$ F
    get_random R3,R7
    ;; R5 <- a_i
    LDR R5, [R0,R12, LSL #2]
    ;; R4 <- b_j
    LDR R4, [R1,R11, LSL #2]
    ;; s_ij = b_j + r
    EOR R4, R3
    ;; p1_ij = a_i * s_ij
    AND R4, R5
    ;; p0_ij = not(a_i)*r
    BIC R5, R3, R5
    ;; c_i += p0_ij + p1_ij
    LDR     R6, [R2,R12, LSL #2]
    EOR R6, R5
    EOR R6, R4
    STR     R6, [R2,R12, LSL #2]

    ;; R5 <- a_j
    LDR R5, [R0,R11, LSL #2]
    ;; R4 <- b_i
    LDR R4, [R1,R12, LSL #2]
    ;; s_ji = b_i + r
    EOR R4, R3
    ;; p1_ji = a_j * s_ji
    AND R4, R5
    ;; p0_ji = not(a_j)*r
    BIC R5, R3, R5
    ;; c_j += p0_ji + p1_ji
    LDR     R6, [R2,R11, LSL #2]
    EOR R6, R5
    EOR R6, R4
    STR     R6, [R2,R11, LSL #2]

    ;; loop 2 processing
    ADD     R11, #1
    CMP     R11, #MASKING_ORDER
    BNE     loop2pini1
    ;; loop 1 processing
    ADD     R12, #1
    CMP     R12, #(MASKING_ORDER-1)
    BNE     loop1pini1

    BX LR
    LTORG
