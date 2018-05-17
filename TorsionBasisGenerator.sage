def torsionBasisGen(IE, ord, Ilb, Ieb, IC):
    O = IE(0)
    primitiveP = false
    while not primitiveP:
        primitiveP = true
        Pl = IE.random_point()
        P = (((Ilb^Ieb)*IC)^2)*Pl
        for k in range(1,ord):
            if ord % k == 0:
                if k*P == O:
                    primitiveP = false
                    break

    primitiveQ = false
    while not primitiveQ:
        primitiveQ = true
        Ql = IE.random_point()
        Q = (((Ilb^Ieb)*IC)^2)*Ql
        if not Q == P:
            for k in range(1,ord):
                if ord % k == 0:
                    if k*Q == O:
                        primitiveQ = false
                        break
            mu = P.weil_pairing(Q,ord)
            for k in range(1,ord):
                if ord % k == 0:
                    if k*mu == 0:
                        primitiveQ = false
                        break
        else:
            primitiveQ = false
    result = []
    result.append(P)
    result.append(Q)
    return result