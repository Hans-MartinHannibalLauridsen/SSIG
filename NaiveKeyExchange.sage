from random import randint
def getRandomSR(Il,Ie, ITE):
    IR = []
    notBothDiv = true
    while len(IR) < 2:
        r = randint(0, Il^Ie-1)
        if (not r % Il == 0) or notBothDiv:
            IR.append(r)
            notBothDiv = false
    IS = IR[0]*ITE[0]+IR[1]*ITE[1]
    result = [IS,IR]
    return result

SRA = getRandomSR(la,ea,TEA)
SA = SRA[0]; RA = SRA[1]

SRB = getRandomSR(lb,eb,TEB)
SB = SRB[0]; RB = SRB[1]

phi = E0.isogeny(SA)
EA = phi.codomain()
phiB = [phi(TEB[0]),phi(TEB[1])]

psi = E0.isogeny(SB)
EB = psi.codomain()
psiA = [psi(TEA[0]),psi(TEA[1])]

SApsi = RA[0]*psiA[0]+RA[1]*psiA[1]

SBphi = RB[0]*phiB[0]+RB[1]*phiB[1]

phil = EB.isogeny(SApsi)
EBA = phil.codomain()

psil = EA.isogeny(SBphi)
EAB = psil.codomain()

EBA.j_invariant()
EAB.j_invariant()