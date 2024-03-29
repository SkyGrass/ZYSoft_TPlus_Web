/****** Object:  Table [dbo].[ZYSoft_L_T_ICMaxNum]    Script Date: 07/08/2019 21:15:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ZYSoft_L_T_ICMaxNum](
	[FTableName] [varchar](50) NOT NULL,
	[FMaxNum] [bigint] NULL,
 CONSTRAINT [Prm_ZYSOFT_T_ICMaxNum] PRIMARY KEY CLUSTERED 
(
	[FTableName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ZYSoft_BillNo]    Script Date: 07/08/2019 21:15:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ZYSoft_BillNo](
	[FYear] [int] NOT NULL,
	[FMonth] [int] NOT NULL,
	[FDay] [int] NOT NULL,
	[FIndex] [int] NOT NULL,
 CONSTRAINT [PK_ZYSoft_BillNo] PRIMARY KEY CLUSTERED 
(
	[FYear] ASC,
	[FMonth] ASC,
	[FDay] ASC,
	[FIndex] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ZYSoft_RecordEntry]    Script Date: 07/08/2019 21:15:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ZYSoft_RecordEntry](
	[FEntryID] [int] IDENTITY(1,1) NOT NULL,
	[FMainItemID] [int] NOT NULL,
	[FWarehouseCode] [varchar](20) NULL,
	[FInvCode] [varchar](50) NULL,
	[FInvName] [varchar](200) NULL,
	[FInvStd] [varchar](200) NULL,
	[FUnitName] [varchar](10) NULL,
	[FPrice] [decimal](18, 2) NULL,
	[FQty] [decimal](18, 2) NULL,
	[FPlanQty] [decimal](18, 2) NULL,
	[FSum] [decimal](18, 2) NULL,
	[FTaxRate] [int] NULL,
	[FTaxPrice] [decimal](18, 2) NULL,
	[FTaxSum] [decimal](18, 2) NULL,
	[FBatchNo] [varchar](50) NULL,
	[FDetailMemo] [varchar](200) NULL,
 CONSTRAINT [PK_ZYSoft_RecordEntry] PRIMARY KEY CLUSTERED 
(
	[FEntryID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ZYSoft_Record]    Script Date: 07/08/2019 21:15:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ZYSoft_Record](
	[FBillID] [int] NOT NULL,
	[FBillNo] [varchar](20) NULL,
	[FDate] [datetime] NULL,
	[FCustCode] [varchar](20) NULL,
	[FReciveTypeCode] [varchar](5) NULL,
	[FWarehouseCode] [varchar](20) NULL,
	[FWarehouseID] [varchar](20) NULL,
	[FWarehouseName] [varchar](50) NULL,
	[FTaxRate] [decimal](18, 2) NULL,
	[FMaker] [varchar](20) NULL,
	[FMemo] [varchar](200) NULL,
	[FIsBuild] [bit] NULL,
	[FBuildDate] [datetime] NULL,
 CONSTRAINT [PK_ZYSoft_Record] PRIMARY KEY CLUSTERED 
(
	[FBillID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
/****** Object:  StoredProcedure [dbo].[ZYSoft_BuildBillNo]    Script Date: 07/08/2019 21:15:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- AUTHOR:		YANG
-- CREATE DATE: <CREATE DATE,,>
-- DESCRIPTION:	<DESCRIPTION,,>
-- =============================================
CREATE PROCEDURE [dbo].[ZYSoft_P_BuildBillNo] 
AS
BEGIN
	-- SET NOCOUNT ON ADDED TO PREVENT EXTRA RESULT SETS FROM
	-- INTERFERING WITH SELECT STATEMENTS.
	SET NOCOUNT ON;

    -- INSERT STATEMENTS FOR PROCEDURE HERE
	IF NOT EXISTS (SELECT 1 FROM ZYSOFT_BILLNO WHERE FYEAR = YEAR(GETDATE())
	AND FMONTH = MONTH(GETDATE()) AND FDAY = DAY(GETDATE()))
	BEGIN 
		INSERT INTO ZYSOFT_BILLNO(FYEAR,FMONTH,FDAY,FINDEX)
		VALUES(YEAR(GETDATE()),MONTH(GETDATE()),DAY(GETDATE()),1)
		
	END
		UPDATE ZYSOFT_BILLNO SET FINDEX = ISNULL(FINDEX,1)+1 WHERE FYEAR = YEAR(GETDATE())
		AND FMONTH = MONTH(GETDATE()) AND FDAY = DAY(GETDATE())
		
		SELECT CAST(YEAR(GETDATE()) AS VARCHAR(4))+
			   CAST(RIGHT(100+MONTH(GETDATE()),2) AS VARCHAR(2))+  
			   CAST(RIGHT(100+DAY(GETDATE()),2) AS VARCHAR(2))+
			   RIGHT('0000'+CAST( FINDEX  AS nvarchar(50)),4) AS FBillNo  FROM ZYSOFT_BILLNO WHERE FYEAR = YEAR(GETDATE())
		AND FMONTH = MONTH(GETDATE()) AND FDAY = DAY(GETDATE())
END
GO
/****** Object:  StoredProcedure [dbo].[ZYSOFT_L_P_GetICMaxNum]    Script Date: 07/08/2019 21:15:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ZYSOFT_L_P_GetICMaxNum]
    @TableName VARCHAR (50),  
    @FInterID  bigint OUTPUT,  
    @Increment bigint = 1  
AS  
    BEGIN TRANSACTION  
      
    UPDATE ZYSOFT_L_T_ICMaxNum  
       SET FMaxNum = FMaxNum  
     WHERE FTableName = @TableName  
      
    IF EXISTS ( SELECT FMaxNum  
                  FROM ZYSOFT_L_T_ICMaxNum  
                 WHERE FTableName = @TableName)  
    BEGIN  
        UPDATE ZYSOFT_L_T_ICMaxNum  
           SET FMaxNum = FMaxNum + @Increment  
         WHERE FTableName = @TableName  
          
        SELECT @FInterID = FMaxNum - @Increment + 1  
          FROM ZYSOFT_L_T_ICMaxNum  
         WHERE FTableName = @TableName  
    END  
    ELSE  
    BEGIN  
        INSERT INTO ZYSOFT_L_T_ICMaxNum(FTableName, FMaxNum)  
             VALUES (@TableName, 999 + @Increment)  
        SELECT @FInterID = 1000  
    END  
    IF @@ERROR = 0  
        COMMIT TRANSACTION  
    ELSE  
    BEGIN  
        ROLLBACK TRANSACTION  
        SELECT @FInterID = -1  
    END  
    RETURN @FInterID
GO
/****** Object:  StoredProcedure [dbo].[ZYSoft_BuildTBill]    Script Date: 07/08/2019 21:15:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Yang
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ZYSoft_BuildTBill]
	@BillId INT = -1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select FCustCode,FReciveTypeCode,FMaker,FMemo,FInvCode,
	FQty,FPlanQty,FPrice,t1.FTaxRate,0 FBillID,0 FEntryID,''FBillNo,FBatchNo,
	t2.FWarehouseCode,FDetailMemo,t2.FTaxPrice,t2.FTaxSum as FTaxAmount
	from ZYSoft_Record t1 left join ZYSoft_RecordEntry t2 on t1.FBillID = t2.FMainItemID
	where t1.FBillID = @BillId and ISNULL(t1.FIsBuild,0)=0
END
GO
/****** Object:  StoredProcedure [dbo].[ZYSOFT_L_P_GetMaxID]    Script Date: 07/08/2019 21:15:11 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ZYSOFT_L_P_GetMaxID]
	@TableName	Varchar(100),
	@Increment bigint = 1 
AS

Declare @MaxID bigint 


Exec ZYSOFT_L_P_GetICMaxNum @TableName,@MaxID OutPut,@Increment

Select @MaxID As FMaxID
GO
