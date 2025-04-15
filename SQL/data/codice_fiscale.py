import datetime

vocali = ['A', 'E', 'I', 'O', 'U']

def getFirstPart(stringa):
  ref = []
  conta_lettere_stringa = 0
  upper_string = stringa.upper()
  for lettera in upper_string:
    if conta_lettere_stringa < 3:
      if lettera not in vocali:
        ref.append(lettera)
        conta_lettere_stringa = conta_lettere_stringa + 1
  if len(ref):
    for lettera in upper_string:
      if conta_lettere_stringa < 3:
        if lettera in vocali:
          ref.append(lettera)
          conta_lettere_stringa = conta_lettere_stringa + 1
  return ''.join(ref)


def getCode(firstname, lastname, date):
  res = getFirstPart(lastname) + getFirstPart(firstname) + date.strftime("%y") + 'B' + date.strftime("%d") + 'G888D'
  return res