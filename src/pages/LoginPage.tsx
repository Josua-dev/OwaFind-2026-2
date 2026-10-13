import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { ShieldCheck, User, Building, Briefcase, Users, LogIn, CheckCircle2 } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { Input } from '@/components/ui/Input';
import { useApp } from '@/context/AppContext';
import type { Role } from '@/types';

const roles: { id: Role; label: string; icon: typeof User; description: string }[] = [
  { id: 'beneficiary', label: 'Beneficiary', icon: User, description: 'I am looking for my benefits' },
  { id: 'institution', label: 'Institution', icon: Building, description: 'I represent an institution' },
  { id: 'regulator', label: 'Regulator', icon: Briefcase, description: 'I am a regulator' },
  { id: 'executive', label: 'Executive', icon: Users, description: 'I am an executive' },
  { id: 'admin', label: 'Admin', icon: ShieldCheck, description: 'I am an administrator' },
];

export function LoginPage() {
  const { switchRole } = useApp();
  const [showRoleSelect, setShowRoleSelect] = useState(false);
  const [selectedRole, setSelectedRole] = useState<Role | null>(null);
  const [formData, setFormData] = useState({
    nationalId: '',
    dateOfBirth: '',
    institutionRef: '',
    password: '',
  });
  const [error, setError] = useState('');

  const roleLabels: Record<Role, string> = {
    beneficiary: 'National ID',
    institution: 'Institution Reference',
    regulator: 'Workspace Email',
    executive: 'Workspace Email',
    admin: 'Workspace Email',
  };

  const rolePlaceholders: Record<Role, string> = {
    beneficiary: 'Enter your beneficiary ID',
    institution: 'Enter institution reference',
    regulator: 'name@example.org',
    executive: 'name@example.org',
    admin: 'name@example.org',
  };

  const handleLogin = (event: React.FormEvent) => {
    event.preventDefault();
    setError('');

    if (!selectedRole) {
      setError('Please select your workspace role');
      return;
    }

    if (showRoleSelect) {
      switchRole(selectedRole);
      return;
    }

    const validForRole =
      selectedRole === 'beneficiary'
        ? formData.nationalId.trim().length > 0 && formData.dateOfBirth.trim().length > 0
        : formData.password.trim().length > 0 || formData.nationalId.trim().length > 0 || formData.institutionRef.trim().length > 0;

    if (!validForRole) {
      setError('Please enter the required local workspace details for this role.');
      return;
    }

    switchRole(selectedRole);
  };

  if (showRoleSelect) {
    return (
      <div className="min-h-screen bg-slate-50 flex items-center justify-center p-4">
        <div className="w-full max-w-md">
          <div className="text-center mb-6">
            <h1 className="font-display text-2xl font-bold text-slate-900 mt-3">Select your role</h1>
            <p className="text-slate-500 mt-1">Choose how you will use the local workspace</p>
          </div>

          <form onSubmit={handleLogin}>
            <Card>
              <div className="p-5">
                {roles.map((role, idx) => (
                  <motion.div
                    key={role.id}
                    initial={{ opacity: 0, y: 10 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: idx * 0.05 }}
                    onClick={() => {
                      setSelectedRole(role.id);
                      if (role.id === 'beneficiary') {
                        setFormData({ nationalId: '', dateOfBirth: '', institutionRef: '', password: '' });
                      } else {
                        setFormData({ nationalId: '', dateOfBirth: '', institutionRef: '', password: '' });
                      }
                    }}
                    className={`flex items-center gap-3 p-3 rounded-lg cursor-pointer hover:bg-slate-50 mb-2 last:mb-0 ${selectedRole === role.id ? 'border border-primary-200' : ''}`}
                  >
                    <div className="w-10 h-10 rounded-lg bg-primary-100 flex items-center justify-center">
                      <role.icon className="w-5 h-5 text-primary-600" />
                    </div>
                    <div>
                      <p className="font-medium text-slate-900">{role.label}</p>
                      <p className="text-xs text-slate-400">{role.description}</p>
                    </div>
                    <AnimatePresence>
                      {selectedRole === role.id && (
                        <motion.div
                          initial={{ scale: 0.8, opacity: 0 }}
                          animate={{ scale: 1, opacity: 1 }}
                          className="ml-auto text-primary-600"
                        >
                          <CheckCircle2 className="w-5 h-5" />
                        </motion.div>
                      )}
                    </AnimatePresence>
                  </motion.div>
                ))}
              </div>
            </Card>

            <Button type="submit" className="w-full mt-4" disabled={!selectedRole}>Continue as {selectedRole && roles.find((r) => r.id === selectedRole)?.label}</Button>
          </form>

          <div className="text-center mt-4">
            <button type="button" onClick={() => setShowRoleSelect(false)} className="text-sm text-slate-400 hover:text-slate-600">← Back to role selection</button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-slate-50 flex items-center justify-center p-4">
      <div className="w-full max-w-md">
        <div className="text-center mb-6">
          <h1 className="font-display text-2xl font-bold text-slate-900 mt-3">Welcome to the Workspace</h1>
          <p className="text-slate-500 mt-1">Local synthetic workspace</p>
        </div>

        <Card>
          <div className="p-5">
            <form onSubmit={handleLogin} className="space-y-4">
              {error && (
                <div className="p-3 bg-error-50 border border-error-200 rounded-lg">
                  <p className="text-sm text-error-600">{error}</p>
                </div>
              )}

              {!showRoleSelect && (
                <Button type="button" variant="outline" className="w-full" onClick={() => setShowRoleSelect(true)}>
                  Select Workspace Role
                </Button>
              )}

              {selectedRole && (
                <>
                  <div className="space-y-2">
                    {selectedRole === 'beneficiary' ? (
                      <>
                        <Input
                          label="National ID"
                          value={formData.nationalId}
                          onChange={(e) => setFormData({ ...formData, nationalId: e.target.value })}
                          placeholder="Enter your national ID"
                        />
                        <Input
                          label="Date of birth"
                          type="date"
                          value={formData.dateOfBirth}
                          onChange={(e) => setFormData({ ...formData, dateOfBirth: e.target.value })}
                        />
                      </>
                    ) : (
                      <>
                        <Input
                          label={roleLabels[selectedRole]}
                          value={selectedRole === 'institution' ? formData.institutionRef : formData.password}
                          onChange={(e) =>
                            selectedRole === 'institution'
                              ? setFormData({ ...formData, institutionRef: e.target.value })
                              : setFormData({ ...formData, password: e.target.value })
                          }
                          placeholder={rolePlaceholders[selectedRole]}
                        />
                        <Input
                          label="Password"
                          type="password"
                          value={formData.password}
                          onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                          placeholder="Enter any local workspace password"
                        />
                      </>
                    )}
                  </div>

                  <Button type="submit" className="w-full" disabled={!selectedRole}>
                    <LogIn className="w-4 h-4" />
                    Continue to workspace
                  </Button>
                </>
              )}
            </form>
          </div>
        </Card>

        <div className="mt-4 text-center text-xs text-slate-500">
          No real authentication is used in this local synthetic workspace.
        </div>
      </div>
    </div>
  );
}
