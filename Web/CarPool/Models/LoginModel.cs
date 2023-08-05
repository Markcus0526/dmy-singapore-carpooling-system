using System;
using System.Collections.Generic;
using System.Globalization;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Configuration;
using System.Data.Linq;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;

namespace CarPool.Models
{
    #region Models
    public class AccountModel
    {
        [Required(ErrorMessage = "UserName is empty.")]
        [DisplayName("UserName:")]
        public string UserName { get; set; }

        [Required(ErrorMessage = "Password is empty.")]
        [ValidatePasswordLenth]
        [DataType(DataType.Password)]
        [DisplayName("Password:")]
        public string Password { get; set; }

        [DisplayName("Remember Password")]
        public bool RememberMe { get; set; }
    }
    #endregion
    [AttributeUsage(AttributeTargets.Field | AttributeTargets.Property, AllowMultiple = false, Inherited = true)]
    public sealed class ValidatePasswordLenthAttribute : ValidationAttribute
    {
        private const string _defaultErrorMessage = "Password length must longger than {0}";
        private readonly int _minCharacters = 6;

        public ValidatePasswordLenthAttribute()
            : base(_defaultErrorMessage)
        {
        }

        public override string FormatErrorMessage(string name)
        {
            return String.Format(CultureInfo.CurrentUICulture, ErrorMessageString, _minCharacters);
        }

        public override bool IsValid(object value)
        {
            string valueAsString = value as string;
            return (valueAsString != null && valueAsString.Length >= _minCharacters);
        }
    }

    public class LoginModel
    {
        CarPoolDataContext dbContext = new CarPoolDataContext(ConfigurationManager.ConnectionStrings["carpoolConnectionString"].ConnectionString);
        //Username and Password Validate Function
        public int ValidatePassword(string pass, string username, bool remember)
        {
            try
            {
                tbl_admin adminInfo = (from m in dbContext.tbl_admins where (m.name.ToLower() == username.ToLower() && m.deleted == 0) select m).FirstOrDefault();
                if (adminInfo == null)
                    return 0;
                else
                {
                    if (adminInfo.password == pass)
                    {
                        string sql = "";
                        if ( remember )
                            sql = "Update tbl_admin Set remember='1' Where uid='" + adminInfo.uid + "'";
                        else
                            sql = "Update tbl_admin Set remember='0' Where uid='" + adminInfo.uid + "'";
                        dbContext.ExecuteCommand(sql);
                        return 2;
                    }
                    else
                    {
                        return 1;
                    }
                }
            }
            catch (System.Exception ex)
            {
                CommonModel.WriteLogFile(this.GetType().Name, "ValidatePassword", ex.ToString());
            }
            return 3;
        }
        //When UserName is changed, get this user's "Password" And "RemeberMe"
        public tbl_admin GetUserStatus( string userName )
        {
            tbl_admin adminInfo = null;
            try
            {
                adminInfo = (from m in dbContext.tbl_admins where (m.name.ToLower() == userName.ToLower() && m.deleted == 0) select m).FirstOrDefault();
            }
            catch (System.Exception ex)
            {
                CommonModel.WriteLogFile(this.GetType().Name, "GetUserStatus", ex.ToString());
            }
            return adminInfo;
        }
    }
}