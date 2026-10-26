
-- 04_testes.sql

USE UniversidadeVenturi;
GO

-- 1. Cadastra um aluno e matricula nas materias de ENG
EXEC procMATRICULAALUNO
    @NOME = 'Aluno Teste',
    @CURSO = 'ENG',
    @PERLETIVO = 2026;
GO

-- 2. Localiza a matricula do aluno criado
DECLARE @MAT INT;

SELECT TOP 1 @MAT = MATRICULA
FROM ALUNOS
WHERE NOME = 'Aluno Teste'
ORDER BY MATRICULA DESC;

-- 3. Cadastra as notas dos quatro bimestres em BDA
EXEC sp_CadastraNotas
    @MATRICULA = @MAT,
    @CURSO = 'ENG',
    @MATERIA = 'BDA',
    @PERLETIVO = 2026,
    @NOTA = 6,
    @FALTA = 2,
    @BIMESTRE = 1;

EXEC sp_CadastraNotas
    @MATRICULA = @MAT,
    @CURSO = 'ENG',
    @MATERIA = 'BDA',
    @PERLETIVO = 2026,
    @NOTA = 6,
    @FALTA = 2,
    @BIMESTRE = 2;

EXEC sp_CadastraNotas
    @MATRICULA = @MAT,
    @CURSO = 'ENG',
    @MATERIA = 'BDA',
    @PERLETIVO = 2026,
    @NOTA = 6,
    @FALTA = 2,
    @BIMESTRE = 3;

EXEC sp_CadastraNotas
    @MATRICULA = @MAT,
    @CURSO = 'ENG',
    @MATERIA = 'BDA',
    @PERLETIVO = 2026,
    @NOTA = 6,
    @FALTA = 2,
    @BIMESTRE = 4;
GO

-- 4. Confere o resultado antes do exame
SELECT
    A.NOME AS ALUNO,
    MA.MATERIA,
    MA.MEDIA,
    MA.PERCFREQ,
    MA.RESULTADO
FROM MATRICULA AS MA
INNER JOIN ALUNOS AS A
    ON A.MATRICULA = MA.MATRICULA
WHERE MA.MATRICULA = (
    SELECT MAX(MATRICULA)
    FROM ALUNOS
)
AND MA.CURSO = 'ENG'
AND MA.MATERIA = 'BDA'
AND MA.PERLETIVO = 2026;
GO

-- 5. Cadastra a nota do exame pela procedure
DECLARE @MATEXAME INT;

SELECT @MATEXAME = MAX(MATRICULA)
FROM ALUNOS;

EXEC sp_CadastraNotaExame
    @MATRICULA = @MATEXAME,
    @CURSO = 'ENG',
    @MATERIA = 'BDA',
    @PERLETIVO = 2026,
    @NOTAEXAME = 8;
GO

-- 6. Confere o resultado final
SELECT
    A.NOME AS ALUNO,
    MA.MATERIA,
    MA.N1,
    MA.N2,
    MA.N3,
    MA.N4,
    MA.MEDIA,
    MA.NOTAEXAME,
    MA.MEDIAFINAL,
    MA.PERCFREQ,
    MA.RESULTADO
FROM MATRICULA AS MA
INNER JOIN ALUNOS AS A
    ON A.MATRICULA = MA.MATRICULA
WHERE MA.MATRICULA = (
    SELECT MAX(MATRICULA)
    FROM ALUNOS
)
AND MA.CURSO = 'ENG'
AND MA.MATERIA = 'BDA'
AND MA.PERLETIVO = 2026;
GO
