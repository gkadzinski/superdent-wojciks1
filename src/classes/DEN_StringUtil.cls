public class DEN_StringUtil {
    public static String getInitials(User user) {
        return (user.FirstName.left(1) + user.LastName.left(1)).toUpperCase();
    }
    
    public static String getInitials(Contact contact) {
        return (contact.FirstName.left(1) + contact.LastName.left(1)).toUpperCase();
    }
}