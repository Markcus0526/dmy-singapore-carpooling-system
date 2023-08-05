using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.Globalization;
using System.Configuration;

namespace CarPool.Models.ChgPasswordModel
{
    #region Models
    public class ChangeModel
    {
        [Required(ErrorMessage = "Old Password is empty.")]
        [DisplayName("Old Password : ")]
        [DataType(DataType.Password)]
        public string OldPassword { get; set; }

        [Required(ErrorMessage = "New Password is empty.")]
        [ValidatePasswordLenth]
        [DataType(DataType.Password)]
        [DisplayName("New Password : ")]
        public string NewPassword { get; set; }

        [Required(ErrorMessage = "Confirm Password is empty.")]
        [ValidatePasswordLenth]
        [DataType(DataType.Password)]
        [DisplayName("Confirm Password : ")]
        public string ConfirmPassword { get; set; }
        
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
    public class ChgPasswordModel
    {
        CarPoolDataContext dbContext = new CarPoolDataContext(ConfigurationManager.ConnectionStrings["carpoolConnectionString"].ConnectionString);
        //Username and Password Validate Function
        public bool CheckOldPassword(string username,string oldpass)
        {
            tbl_admin user_info = (from u in dbContext.tbl_admins
                                   where (u.name == username && u.deleted == 0)
                                   select u
                                   ).FirstOrDefault();
            if (user_info.password != oldpass)
                return false;
            return true;
        }
        public bool UpdatePassword(string username,string newpass)
        {
            string strSQL = "UPDATE tbl_admin SET remember=0, password = '"+newpass+"' WHERE name='"+username+"'";
            try
            {
                dbContext.ExecuteCommand(strSQL);
            }
            catch {
                return false;
            }
            return true;
        }
    }
}
