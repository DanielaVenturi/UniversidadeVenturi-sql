--03_cadastrar_notas.sql

USE UniversidadeVenturi;
GO

CREATE OR ALTER PROCEDURE sp_CadastraNotas
    @MATRICULA INT,
    @CURSO CHAR(3),
    @MATERIA CHAR(3),
    @PERLETIVO INT,
    @NOTA FLOAT,
    @FALTA INT,
    @BIMESTRE INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @NOTA IS NULL OR @NOTA < 0 OR @NOTA > 10
    BEGIN
        RAISERROR('A nota deve estar entre 0 e 10.', 16, 1);
        RETURN;
    END;

    IF @FALTA IS NULL OR @FALTA < 0
    BEGIN
        RAISERROR('A quantidade de faltas nao pode ser negativa.', 16, 1);
        RETURN;
    END;

    IF @BIMESTRE NOT IN (1, 2, 3, 4)
    BEGIN
        RAISERROR('O bimestre deve ser 1, 2, 3 ou 4.', 16, 1);
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
        RAISERROR(
            'Matricula nao encontrada para os dados informados.',
            16, 1
        );
        RETURN;
    END;

    IF @BIMESTRE = 1
        UPDATE MATRICULA
        SET N1 = @NOTA, F1 = @FALTA
        WHERE MATRICULA = @MATRICULA
          AND CURSO = @CURSO
          AND MATERIA = @MATERIA
          AND PERLETIVO = @PERLETIVO;

    IF @BIMESTRE = 2
        UPDATE MATRICULA
        SET N2 = @NOTA, F2 = @FALTA
        WHERE MATRICULA = @MATRICULA
          AND CURSO = @CURSO
          AND MATERIA = @MATERIA
          AND PERLETIVO = @PERLETIVO;

    IF @BIMESTRE = 3
        UPDATE MATRICULA
        SET N3 = @NOTA, F3 = @FALTA
        WHERE MATRICULA = @MATRICULA
          AND CURSO = @CURSO
          AND MATERIA = @MATERIA
          AND PERLETIVO = @PERLETIVO;

    IF @BIMESTRE = 4
        UPDATE MATRICULA
        SET N4 = @NOTA, F4 = @FALTA
        WHERE MATRICULA = @MATRICULA
          AND CURSO = @CURSO
          AND MATERIA = @MATERIA
          AND PERLETIVO = @PERLETIVO;

    UPDATE MATRICULA
    SET
        TOTALPONTOS = ISNULL(N1, 0) + ISNULL(N2, 0)
                    + ISNULL(N3, 0) + ISNULL(N4, 0),
        MEDIA = (
            ISNULL(N1, 0) + ISNULL(N2, 0)
            + ISNULL(N3, 0) + ISNULL(N4, 0)
        ) / 4.0,
        TOTALFALTAS = ISNULL(F1, 0) + ISNULL(F2, 0)
                    + ISNULL(F3, 0) + ISNULL(F4, 0)
    WHERE MATRICULA = @MATRICULA
      AND CURSO = @CURSO
      AND MATERIA = @MATERIA
      AND PERLETIVO = @PERLETIVO;

    IF @BIMESTRE = 4
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM MATRICULA
            WHERE MATRICULA = @MATRICULA
              AND CURSO = @CURSO
              AND MATERIA = @MATERIA
              AND PERLETIVO = @PERLETIVO
              AND (
                  N1 IS NULL
                  OR N2 IS NULL
                  OR N3 IS NULL
                  OR N4 IS NULL
              )
        )
        BEGIN
            RAISERROR(
                'Nao e possivel calcular o resultado: faltam notas de algum bimestre.',
                16, 1
            );
            RETURN;
        END;

        DECLARE @CARGAHORARIA INT;
        DECLARE @TOTALFALTAS INT;
        DECLARE @MEDIA FLOAT;
        DECLARE @FREQUENCIA FLOAT;
        DECLARE @RESULTADO VARCHAR(20);

        SELECT
            @CARGAHORARIA = M.CARGAHORARIA,
            @TOTALFALTAS = MA.TOTALFALTAS,
            @MEDIA = MA.MEDIA
        FROM MATRICULA AS MA
        INNER JOIN MATERIAS AS M
            ON M.SIGLA = MA.MATERIA
        WHERE MA.MATRICULA = @MATRICULA
          AND MA.CURSO = @CURSO
          AND MA.MATERIA = @MATERIA
          AND MA.PERLETIVO = @PERLETIVO;

        SET @FREQUENCIA =
            (1.0 - (
                CONVERT(FLOAT, @TOTALFALTAS)
                / NULLIF(@CARGAHORARIA, 0)
            )) * 100;

        IF @FREQUENCIA < 0
            SET @FREQUENCIA = 0;

        IF @FREQUENCIA < 75
            SET @RESULTADO = 'REPROVADO';
        ELSE IF @MEDIA >= 7
            SET @RESULTADO = 'APROVADO';
        ELSE IF @MEDIA >= 4
            SET @RESULTADO = 'EXAME';
        ELSE
            SET @RESULTADO = 'REPROVADO';

        UPDATE MATRICULA
        SET
            PERCFREQ = @FREQUENCIA,
            MEDIAFINAL = @MEDIA,
            RESULTADO = @RESULTADO
        WHERE MATRICULA = @MATRICULA
          AND CURSO = @CURSO
          AND MATERIA = @MATERIA
          AND PERLETIVO = @PERLETIVO;
    END;

    SELECT *
    FROM MATRICULA
    WHERE MATRICULA = @MATRICULA
      AND CURSO = @CURSO
      AND MATERIA = @MATERIA
      AND PERLETIVO = @PERLETIVO;
END;
GO
