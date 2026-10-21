/*procedure de matrícula automática*/


USE UniversidadeVenturi;
GO

CREATE OR ALTER PROCEDURE procMATRICULAALUNO
    @NOME VARCHAR(50),
    @CURSO CHAR(3),
    @PERLETIVO CHAR(4)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MATRICULA INT;

    IF NOT EXISTS (
        SELECT 1
        FROM CURSOS
        WHERE CURSO = @CURSO
    )
    BEGIN
        RAISERROR('Curso nao encontrado.', 16, 1);
        RETURN;
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM MATERIAS
        WHERE CURSO = @CURSO
    )
    BEGIN
        RAISERROR('Este curso nao possui materias cadastradas.', 16, 1);
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO ALUNOS (NOME)
        VALUES (@NOME);

        SET @MATRICULA = CONVERT(INT, SCOPE_IDENTITY());

        INSERT INTO MATRICULA (
            MATRICULA,
            CURSO,
            MATERIA,
            PROFESSOR,
            PERLETIVO
        )
        SELECT
            @MATRICULA,
            M.CURSO,
            M.SIGLA,
            M.PROFESSOR,
            @PERLETIVO
        FROM MATERIAS AS M
        WHERE M.CURSO = @CURSO;

        COMMIT TRANSACTION;

        SELECT
            @MATRICULA AS MATRICULA,
            @NOME AS NOME,
            @CURSO AS CURSO,
            @PERLETIVO AS PERLETIVO;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO
