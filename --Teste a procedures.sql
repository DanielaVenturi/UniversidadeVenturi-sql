--Teste a procedures

USE UniversidadeVenturi;
GO

EXEC procMATRICULAALUNO
    @NOME = 'Aluno Teste',
    @CURSO = 'ENG',
    @PERLETIVO = '2026';
GO
