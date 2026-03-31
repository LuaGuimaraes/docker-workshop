import sys 

# print('arguments', sys.argv) # sys.argv é uma lista que contém os argumentos passados para o script, 
# onde o primeiro elemento é o nome do script e os demais elementos são os argumentos passados para o script

#month = int(sys.argv[1]) # pega o segundo elemento da lista, que é o primeiro argumento passado para o script, e converte para inteiro

#print(f'Hello, pipeline.py! Month: {month}')


import pandas as pd

df = pd.DataFrame({"A": [1, 2, 3], "B": [4, 5, 6]}) # cria um DataFrame com duas colunas, A e B, e 
# três linhas de dados

print(df * 2)
print(df.head())


df.to_parquet("output.parquet")

