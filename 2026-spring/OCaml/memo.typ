#import "/template.typ": frame, setup
#show: setup

$
  S &= lambda x.lambda y.lambda z. (x z) (y z)\
  K &= lambda x.(lambda y. x)\
  ((S K) K) x
  &= ((lambda x.lambda y.lambda z. (x z) (y z) K) K) x\
  &= (lambda y.lambda z. (K z) (y z)  K) x\
  &= (lambda y.lambda z. (lambda x.(lambda y. x) z) (y z)  K) x\
  &= (lambda y.lambda z. (lambda y.z) (y z)  K) x\
  &= (lambda z. (lambda y.z) (K z))   x\
  &= (lambda z. (lambda y.z) (lambda x.(lambda y. x) z))   x\
  &= (lambda z. (lambda y.z) (lambda y. z))   x\
  &= (lambda y.x) (lambda y. x)\
  &= x
$