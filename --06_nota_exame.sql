--06_nota_exame.sql
USE UniversidadeVenturi;
GO

CREATE OR ALTER PROCEDURE sp_CadastraNotaExame
    @MATRICULA INT,
    @CURSO CHAR(3),
    @MATERIA CHAR(3),
    @PERLETIVO INT,
    @NOTAEXAME FLOAT
AS
BEGIN
    SET NOCOUNT ON;

    IF @NOTAEXAME IS NULL
       OR @NOTAEXAME < 0
       OR @NOTAEXAME > 10
    BEGIN
        RAISERROR(
            'A nota do exame deve estar entre 0 e 10.',
            16, 1
        );
        RETURN;
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM MATRICULA
        WHERE MATRICULA = @MATRICULA
          AND CURSO = @CURSO
          AND MATERIA = @MATERIA
          AND PERLETIVO = @PERLETIVO
    )
    BEGIN
        RAISERROR('Matricula nao encontrada.', 16, 1);
        RETURN;
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM MATRICULA
        WHERE MATRICULA = @MATRICULA
          AND CURSO = @CURSO
          AND MATERIA = @MATERIA
          AND PERLETIVO = @PERLETIVO
          AND RESULTADO = 'EXAME'
    )
    BEGIN
        RAISERROR(
            'O aluno nao possui resultado EXAME nesta materia.',
            16, 1
        );
        RETURN;
    END;

    UPDATE MATRICULA
    SET
        NOTAEXAME = @NOTAEXAME,
        MEDIAFINAL = (MEDIA + @NOTAEXAME) / 2.0,
        RESULTADO = CASE
            WHEN PERCFREQ < 75 THEN 'REPROVADO'
            WHEN (MEDIA + @NOTAEXAME) / 2.0 >= 5 THEN 'APROVADO'
            ELSE 'REPROVADO'
        END
    WHERE MATRICULA = @MATRICULA
      AND CURSO = @CURSO
      AND MATERIA = @MATERIA
      AND PERLETIVO = @PERLETIVO;

    SELECT *
    FROM MATRICULA
    WHERE MATRICULA = @MATRICULA
      AND CURSO = @CURSO
      AND MATERIA = @MATERIA
      AND PERLETIVO = @PERLETIVO;
END;
GO
